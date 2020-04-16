#!/usr/bin/env ruby
# (partially) converts RIOASM to Ren'Py script 

require_relative 'opcode'
require_relative 'op2rpy_settings_enum'
require_relative 'op2rpy_settings'
include O2RSettingsEnum
include O2RSettings

module RIOASMTranslator
    def translate(scr_name, scr)
        @rpy = RpyGenerator.new
        @gfx = {:bg => "", :bg_redraw => false, :fg => [], :fg_redraw => false, :obj => nil, :obj_redraw => false, :em => nil}
        @index = 0
        @code_block_ends_at = []
        @jmp_trigger = []
        @scr = scr
        @scr_name = scr_name
        @rpy.add_comment("Generated by op2rpy, edit with caution.")
        @rpy.add_cmd("label RIO_#{scr_name}:")
        @rpy.begin_block()
        @scr.each do |cmd|
            _check_code_block(cmd[0])
            _check_absjump_tag(cmd[0])
            if respond_to?("op_#{cmd[1]}")
                @rpy.add_comment("[cmd] #{_generate_cmd_disasm(cmd)}") if FORCE_INCLUDE_DISASM
                send("op_#{cmd[1]}", *cmd[2..-1])
            else
                @rpy.add_comment("[cmd:unhandled] #{_generate_cmd_disasm(cmd)}")
            end
            @index += 1
        end
        @rpy.end_block()
        return @rpy.script
    end

    def _generate_cmd_disasm(cmd)
        return "0x#{cmd[0].to_s(16)}:#{cmd[1]}(#{cmd[2..-1].to_s.gsub(/[\[\]]/, '')})"
    end

    def _check_code_block(cur_offset)
        if @code_block_ends_at[-1] == cur_offset
            @rpy.end_block()
            @code_block_ends_at.pop()
            _check_code_block(cur_offset)
        end
    end
    
    def _check_absjump_tag(cur_offset)
        if @jmp_trigger.include?(cur_offset)
            @rpy.end_block()
            @rpy.add_cmd("label RIO_#{@scr_name}_#{cur_offset}:")
            @rpy.begin_block()
            @jmp_trigger.delete(cur_offset)
        end
    end

    def _get_flag_reference(flag_addr, on_hint)
        bank = nil
        FLAG_BANKS.each do |b|
            if flag_addr.between?(b[0], b[1])
                bank = b[2]
                break
            end
        end
        if bank.nil?
            @rpy.add_comment("[warning:_get_flag_reference] Access to unmapped flag address #{flag_addr}")
            return nil
        end
        v = FLAG_TABLE[flag_addr]
        # Check for excluded or hinted flags
        if v
            # Labeled flag or requires special care
            flag_ref = "#{bank}[#{(v[0].nil?) ? flag_addr : ("'#{v[0]}'")}]"
            if v[1] == Flag::EXCLUDE
                return nil
            elsif v[1] == Flag::HINT
                @rpy.add_comment(on_hint.call(flag_ref))
                return nil
            elsif v[1] == Flag::INCLUDE
                return flag_ref
            else
                raise 'Invalid flag inclusion policy.'
            end
        else
            # Unlabeled flag
            return "#{bank}[#{flag_addr}]"
        end
    end

    def op_call(label)
        @rpy.add_cmd("call RIO_#{label.upcase()}")
    end

    def op_return()
        @rpy.add_cmd('return')
    end

    def op_option(*args)
        raise 'Wrong number of parameters' if (args.length % 6) != 0

        @rpy.add_cmd("menu:")
        @rpy.begin_block()
        (args.length / 6).times do |i|
            opt = args[(i * 6)..((i + 1) * 6)]
            opt[1].encode!('utf-8', RIO_TEXT_ENCODING)
            @rpy.add_cmd("\"#{opt[1]}\":")
            @rpy.begin_block()
            @rpy.add_cmd("jump RIO_#{opt[5].upcase()}")
            @rpy.end_block()
        end
        @rpy.end_block()
    end

    # TODO flag operations
    def op_set(operator, lvar, is_flag, rside, try_boolify=false)
        if try_boolify and rside.between?(0, 1)
            rside = rside == 0 ? 'False' : 'True'
        end
        flag_ref = _get_flag_reference(lvar, ->(ref) { return "$ #{ref} #{operator} #{rside}" })
        @rpy.add_cmd("$ #{flag_ref} #{operator} #{rside}") if not flag_ref.nil?
    end

    def op_mov(lvar, is_flag, rside)
        op_set('=', lvar, is_flag, rside, try_boolify=true)
    end

    def op_add(lvar, is_flag, rside)
        op_set('+=', lvar, is_flag, rside)
    end

    def op_sub(lvar, is_flag, rside)
        op_set('-=', lvar, is_flag, rside)
    end

    def op_mul(lvar, is_flag, rside)
        op_set('*=', lvar, is_flag, rside)
    end

    def op_div(lvar, is_flag, rside)
        op_set('/=', lvar, is_flag, rside)
    end

    def op_rnd(lvar, is_flag, rside)
        flag_ref = _get_flag_reference(lvar, ->(ref) { return "$ #{ref} = renpy.random.randint(0, #{rside})" })
        # TODO double-inclusive or upper-exclusive (Python-like)?
        @rpy.add_cmd("$ #{flag_ref} = renpy.random.randint(0, #{rside})") if not flag_ref.nil?
    end

    # TODO Can we translate this to an if...else statement?
    def op_jmp_offset(offset)
        @rpy.add_cmd("jump RIO_#{@scr_name}_#{offset}")
        @jmp_trigger << offset
    end

    def op_jmp(operator, lvar, rside, rel_offset)
        flag_ref = _get_flag_reference(lvar, ->(ref) { return "if #{ref} #{operator} #{rside}: ..." })
        if flag_ref.nil?
            # Evaluate cjmp to always be false in case the flag is inaccessible.
            @rpy.add_comment("[warning:jmp] Attempt to access inaccessible flag #{lvar} in cjmp. Evaluating to false.")
            @rpy.add_cmd("if False:")
        else
            @rpy.add_cmd("if #{flag_ref} #{operator} #{rside}:")
        end
        @rpy.begin_block()
        @code_block_ends_at << (@scr[@index + 1][0] + rel_offset)
    end

    def op_jbe(lvar, rside, rel_offset)
        return op_jmp('>=', lvar, rside, rel_offset)
    end

    def op_jle(lvar, rside, rel_offset)
        return op_jmp('<=', lvar, rside, rel_offset)
    end

    def op_jbt(lvar, rside, rel_offset)
        return op_jmp('>', lvar, rside, rel_offset)
    end

    def op_jlt(lvar, rside, rel_offset)
        return op_jmp('<', lvar, rside, rel_offset)
    end

    def op_jeq(lvar, rside, rel_offset)
        return op_jmp('==', lvar, rside, rel_offset)
    end

    def op_jne(lvar, rside, rel_offset)
        return op_jmp('!=', lvar, rside, rel_offset)
    end

    def op_bg(arg1,arg2,arg3,arg4,arg5,bgname)
        if bgname != @gfx[:bg]
            @gfx[:bg] = bgname
            @gfx[:bg_redraw] = true
        end
    end

    def op_fg(index,xabspos,yabspos,arg4,arg5,arg6,arg7,fgname)
        if fgname != (@gfx[:fg][index][0] rescue nil)
            @gfx[:fg][index] = [fgname, xabspos, yabspos]
            @gfx[:fg_redraw] = true
        end
    end

    def op_obj(xabspos, yabspos, arg3, arg4, arg5, objname)
        if @gfx[:obj].nil? or objname != @gfx[:obj][0]
            @gfx[:obj] = [objname, xabspos, yabspos]
            @gfx[:obj_redraw] = true
        end
    end

    def op_em(emname)
        @gfx[:em] = "#{emname}"
        @rpy.add_cmd("$ side_image_override = \"Chip/#{@gfx[:em].upcase()}.png\"")
    end

    def op_hide_em()
        @rpy.add_cmd("$ side_image_override = None")
        @gfx[:em] = nil
    end

    #0x21
    def op_bgm(repeat, fadein, arg3, filename)
        cmd = "play music \"Bgm/#{filename}.OGG\""
        cmd << " fadein #{fadein / 1000.0}" if fadein != 0
        # The BGM seems to loop even if repeat is 1?
        #case repeat
        #when 0
        #    cmd << " loop"
        #when 1
        #    cmd << " noloop"
        #else
        #    cmd << " loop \# #{repeat} loops"
        #end
        cmd << ' loop'
        @rpy.add_cmd(cmd)
    end

    def op_bgm_stop(arg1, fadeout)
        cmd = "stop music"
        cmd << " fadeout #{fadeout / 1000.0}" if fadeout != 0
        @rpy.add_cmd(cmd)
    end

    def op_se(channel, repeat, is_blocking, offset, fadein, volume, filename)
        cmd = 'play '
        ch_name = 'sound'
        if channel != 0
            ch_name << "#{channel + 1}"
            @rpy.add_cmd("\# [patch:sound_channel.rpy] renpy.music.register_channel('#{ch_name}', 'sfx', False)")
        end
        cmd << ch_name << " \"Se/#{filename}\""
        cmd << " fadein #{fadein / 1000.0}" if fadein != 0
        if repeat == 255 # Loop "forever"
            cmd << ' loop'
        elsif repeat != 0
            cmd << " loop \# #{repeat} loops"
        end
        @rpy.add_cmd(cmd)
    end

    def op_se_stop(channel)
        cmd = 'stop '
        ch_name = 'sound'
        if channel != 0
            ch_name << "#{channel + 1}"
            @rpy.add_comment("[patch:sound_channel.rpy] renpy.music.register_channel('#{ch_name}', 'sfx', False)")
        end
        cmd << ch_name
        @rpy.add_cmd(cmd)
    end

    def op_voice(ch,arg2,arg3,type,arg5,filename)
        @rpy.add_cmd("voice \"Voice/#{filename}.OGG\"")
    end

    #0x41
    def op_text_n(id, text)
        text.encode!('utf-8', RIO_TEXT_ENCODING)
        @rpy.add_cmd("\"#{text}\"")
    end

    #0x42
    def op_text_c(id, name, text)
        name.encode!('utf-8', RIO_TEXT_ENCODING)
        text.encode!('utf-8', RIO_TEXT_ENCODING)
        chara_sym = CHARACTER_TABLE.key(name)
        if CHARACTER_TABLE_LOOKUP and chara_sym
            @rpy.add_cmd("#{chara_sym} \"#{text}\"")
        else
            @rpy.add_cmd("\"#{name}\" \"#{text}\"")
        end
    end

    #0x54
    def op_set_trans_mask(filename)
        @gfx[:trans_mask] = filename
        @rpy.add_comment("[gfx] trans_mask = #{filename}")
    end

    def op_transition(type, duration)
        flush_gfx()
        case type #TODO
        when 'none'
            # "none" on willplus engine will at least persist the object 1 frame. Used for strobe effect in some cases.
            @rpy.add_cmd("with Pause(0.016)")
        when 'fade_out'
            @rpy.add_cmd("with Dissolve(#{duration/1000.0})")
        when 'fade_in'
            @rpy.add_cmd("with Dissolve(#{duration/1000.0})")
        when 'mask'
            @rpy.add_cmd("with ImageDissolve(\"Chip/#{@gfx[:trans_mask]}.png\", #{duration/1000.0}, 256, reverse=True)")
        when 'mask_r'
            @rpy.add_cmd("with ImageDissolve(\"Chip/#{@gfx[:trans_mask]}.png\", #{duration/1000.0}, 256)")
        when 'mask_blend'
            @rpy.add_cmd("with ImageDissolve(\"Chip/#{@gfx[:trans_mask]}.png\", #{duration/1000.0}, 256, reverse=True)")
        when 'mask_blend_r'
            @rpy.add_cmd("with ImageDissolve(\"Chip/#{@gfx[:trans_mask]}.png\", #{duration/1000.0}, 256)")
        else
            @rpy.add_comment("[warning:transition] unknown method #{type}, time: #{duration/1000.0}")
        end
    end

    # TODO graphic_fx
    # graphic_fx(1, 2, 6) screen shake

    # 0x82 TODO
    def op_sleep(ms)
        @rpy.add_cmd("pause #{ms / 1000.0}")
    end

    def op_goto(scr)
        @rpy.add_cmd("jump RIO_#{scr}")
    end

    def op_eof()
        # pass
    end

    def op_video(unskippable, videofile)
        @rpy.add_cmd("$ renpy.movie_cutscene('Videos/#{videofile}')")
    end

    # TODO Figure out where fg is located (Looks like layer1 but vnvm said it's on layer2. Can we trust vnvm?)
    def op_layer1_cl(index)
        @rpy.add_comment("[layer1] cl #{index}")
        if not @gfx[:fg][index].nil?
            # Flag for hiding
            @gfx[:fg][index][0] = nil
            @gfx[:fg][index][1] = -1
            @gfx[:fg][index][2] = -1
            @gfx[:fg_redraw] = true
        end
    end

    def op_obj_cl(arg1)
        @rpy.add_comment("[obj] cl")
        if not @gfx[:obj].nil?
            # Flag for hiding
            @gfx[:obj][0] = nil
            @gfx[:obj][1] = -1
            @gfx[:obj][2] = -1
            @gfx[:obj_redraw] = true
        end
    end

    def flush_gfx()
        bg_redrew = @gfx[:bg_redraw]
        if @gfx[:bg_redraw]
            cmd = "scene bg #{@gfx[:bg]}"
            @rpy.add_cmd(cmd)
            @gfx[:bg_redraw] = false
        end
        
        if @gfx[:fg_redraw]
            @gfx[:fg].each_with_index do |f, i|
                if (not f.nil?) and (not f[0].nil?)
                    @rpy.add_cmd("show fg #{f[0]} as fg_i#{i}:")
                    @rpy.begin_block()
                    @rpy.add_cmd("xpos #{f[1] / 800.0}")
                    @rpy.add_cmd("ypos #{f[2] / 600.0}")
                    @rpy.add_cmd("anchor (0, 0)")
                    @rpy.end_block()
                elsif (not f.nil?) and f[0].nil?
                    # If the layer was flagged for hiding, hide and free the object.
                    @rpy.add_cmd("hide fg_i#{i}") if not bg_redrew
                    @gfx[:fg][i] = nil
                end
            end
            @gfx[:fg_redraw] = false
        end
        if @gfx[:obj_redraw]
            if (not @gfx[:obj].nil?) and (not @gfx[:obj][0].nil?)
                @rpy.add_cmd("show obj #{@gfx[:obj][0]} as obj_i0:")
                @rpy.begin_block()
                @rpy.add_cmd("xpos #{@gfx[:obj][1] / 800.0}")
                @rpy.add_cmd("ypos #{@gfx[:obj][2] / 600.0}")
                @rpy.add_cmd("anchor (0, 0)")
                @rpy.end_block()
            elsif (not @gfx[:obj].nil?) and @gfx[:obj][0].nil?
                # If the layer was flagged for hiding, hide and free the object.
                @rpy.add_cmd("hide obj_i0") if not bg_redrew
                @gfx[:obj] = nil
            end
            @gfx[:obj_redraw] = false
        end
    end

    def debug(message)
        STDERR.write("#{message}\n")
    end
end

class RpyGenerator
    def initialize()
        @script = ''
        @lineno=0
        @indent = 0
        @empty_block = []
    end

    def add_line(*lines)
        indent_str = " " * 2 * @indent 
        lines.each do |line|
        @script << "#{indent_str}#{line}\n"
        @lineno += lines.length
        end
    end

    def add_cmd(*lines)
        add_line(*lines)
        @empty_block[-1] = false if @indent > 0
    end

    def add_comment(*lines)
        lines.each do |line|
            add_line("\# #{line}")
        end
    end

    def begin_block()
        @indent += 1
        @empty_block << true
    end

    def end_block()
        add_cmd('pass') if @empty_block.pop() == true
        @indent -= 1
    end

    attr_accessor :script
end

include RIOASMTranslator
File.open(ARGV[1], 'w') do |f|
    f.write(translate(File.basename(ARGV[0]).split('.')[0], RIOOpCode.decode_script(IO.binread(ARGV[0]), true)))
end
