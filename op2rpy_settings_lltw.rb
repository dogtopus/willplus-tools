require_relative 'op2rpy_settings_enum'
include O2RSettingsEnum

module O2RSettings
    # Set version of opcode (nil == don't set and keep the default)
    # Supported versions: :default (the default), :ymk (variant used by Yume Miru Kusuri and possibly earlier WillPlus games)
    OPCODE_VERSION = nil

    # Include the exact zorder instead of using the natural order. Some games require this for accurate character image placement.
    ACCURATE_ZORDER = false

    # Use the new ATL matrixcolor API for tint() implementation, etc.
    USE_ATL_MATRIXCOLOR = false

    # Use GFX helpers that depends on features that are not yet available in stable Ren'Py.
    USE_GFX_NEXT = false

    # Always include disassembly inside the emitted code. Useful for debugging emitter.
    FORCE_INCLUDE_DISASM = true

    RIO_TEXT_ENCODING = 'big5'

    RESOLVE_EMOJI_SUBSTITUDE = false
    EMOJI_FONT = 'NotoEmoji-Regular.ttf'
    EMOJI_TABLE = {
        '＠' => '❤️',
        '＄' => '💧',
        '＃' => '💢',
        '”' => '💦',
        '︼' => '💡',
        '＊' => '💀',
    }

    MOVE_PREVIOUS_SAY_INTO_MENU = true

    CHARACTER_TABLE_LOOKUP = true
    # Character namespace. Can be nil or a Python name. Will be added to the character object name as a prefix with a dot between the namespace name and character object name. (#{CHARACTER_TABLE_NS}.#{some_chara})
    CHARACTER_TABLE_NS = 'chara'
    CHARACTER_TABLE = {
        'd' => '迪克',
        'i' => '伊恩',
        'r' => '羅迪',
        't' => '托瑪',
        'p' => '皮耶',
        'c' => '柯奈爾',
        'a' => '艾比',
        'da' => '道格',
        'gr' => '葛列格',
        'gu' => '奇瑞德',
        's' => '瑟爾基',
        'n' => '諾思布魯克',
        'l' => '莉夏',
        'l2' => '莉絲',
        'o' => '奧茲華',
        'z' => '札迦萊亞',
        'x' => '？？？',
    }

    CHARACTER_PROPS = {
        'd' => {'who_color' => '#ff4b4b'},
        'i' => {'who_color' => '#d154cb'},
        'r' => {'who_color' => '#ffae4c'},
        't' => {'who_color' => '#b8864d'},
        'p' => {'who_color' => '#b5003f'},
        'c' => {'who_color' => '#ffff00'},
        'a' => {'who_color' => '#9fff6e'},
        'da' => {'who_color' => '#de9658'},
        'gr' => {'who_color' => '#7578ff'},
        'gu' => {'who_color' => '#8e3eae'},
        's' => {'who_color' => '#a2faff'},
        'n' => {'who_color' => '#49ff55'},
        'l' => {'who_color' => '#ffa5a3'},
        'l2' => {'who_color' => '#ffa5a3'},
        'o' => {'who_color' => '#d8d800'},
        'z' => {'who_color' => '#6e53ff'},
        'x' => {'who_color' => '#7f7f7f'},
    }

    # Expression that are evaluated when specified procedures are called.
    PROC_EXTRA_EXPR = {
        'LIST_VIW' => "@gfx[:fg][3] = WillPlusStubDisplayable.new('screen gem_37564_sacrifice_list')"
    }

    # Detect if the animation is wrapped inside a CJMP block that checks if a flag named 'skipping' is 0 or 1. If so only draw the case when the flag is 0.
    # Note that this is a workaround and will likely disappear when proper optimization is implemented in place.
    HACK_DETECT_ANIMATION_SKIP = true

    # Remove orphan with statements (not paired with any show/hide/scene statement)
    REMOVE_ORPHAN_WITH = true

    # Generate code for hentai skip
    # Compatible with https://renpy.org/wiki/renpy/doc/cookbook/Making_adult_scenes_optional
    GEN_HENTAI_SKIP_LOGIC = true

    # Ranges for hentai scenes
    # [[start_label, start_offset, insert_transition], [end_label, end_offset, insert_transition]]
    # WARNING: Replay behavior on hentai scenes are undefined when hentai skip is enabled. So make sure to block replay when hentai skip is enabled by the user. 
    HENTAI_RANGES = [
        [['08_2900', 0x0, true], ['08_2900', 0x258b, false]],
        [['09_1600', 0x0, true], ['09_1600', 0x22c9, false]],
        [['22_0700', 0x91, true], ['22_0700', 0x1822, false]],
        [['22_0700', 0x2e2e, true], ['22_0700', 0x360c, false]],
        [['25_2200', 0x6a, true], ['25_2200', 0x3441, false]],
        [['28_1110', 0x4a5, true], ['28_1110', 0x2e9b, false]],
    ]

    # Override explicit images that are not a part of the hentai scene (e.g. flashbacks) to something safe.
    # Note that this does not skip explicit dialogues. Use HENTAI_RANGES without transitions for those.
    # (Maybe add a dedicated entry for those if they are really needed.)
    HENTAI_IMAGE_OVERRIDE = {
        'EV62A' => 'WHITE',
        'EV62B' => 'WHITE',
    }

    # Show weather on specified layer, or default if there's no layer specified.
    WEATHER_LAYER = 'weather'

    # Whether or not to only use symbols to reference audio. Set to false makes the generated rpy scripts more portable. Set to true results in less boilerplate but requires change to the default audio file prefixes/suffixes.
    AUDIO_SYMBOL_ONLY = true

    # Flagbanks mappings. WARNING: change this after release will cause save incompatibilities.
    FLAG_BANKS = [
        # Double inclusive
        [0, 999, 'will_flagbank'],
        [1000, 2999, 'persistent.will_flagbank'],
    ]

    # Flag table. Change names will not cause save incompatibilities as long as the flag addresses are kept intact.
    # addr => [name, inclusion_policy, category]
    # addr: 16-bit address of the flag.
    # name: The name of the variable. Setting to nil will allow other fields (e.g. inclusion policy) to be specified but keep the flag anonymous.
    # inclusion_policy:
    #   Flag::INCLUDE: Include the flag in the emitted .rpy files with full read/write access.
    #   Flag::EXCLUDE: Exclude the flag in the emitted .rpy files. CJMPs that use it will always be evaluated to false.
    #   Flag::HINT: Similar to Flag::EXCLUDE but inserts a comment instead of completely omitting it.
    # category:
    #   FlagCategory::UNCATEGORIZED: Uncategorized.
    #   FlagCategory::STORY: Story related (i.e. used as a branching condition during the story-telling)
    #   FlagCategory::UNLOCK: Unlocks gallery/event entries
    #   FlagCategory::SYSTEM: Flags used by the infrastructure (non-story) code as temporary or persistent variables.
    FLAG_TABLE = {
        1 => ['help_biscal', Flag::INCLUDE, FlagCategory::STORY],
        2 => ['dessert_house', Flag::INCLUDE, FlagCategory::STORY],
        3 => ['gem_37564_first_seen', Flag::INCLUDE, FlagCategory::STORY],
        4 => ['gem_37564_seen_again', Flag::INCLUDE, FlagCategory::STORY],
        7 => ['sergi_knew_dick_turned_blue', Flag::INCLUDE, FlagCategory::STORY],
        9 => ['aby_escaped', Flag::INCLUDE, FlagCategory::STORY],
        21 => ['did_target_practice', Flag::INCLUDE, FlagCategory::STORY],
        22 => ['called_guillered', Flag::INCLUDE, FlagCategory::STORY],
        23 => ['rescue_cornel', Flag::INCLUDE, FlagCategory::STORY],
        43 => ['asked_roddy_for_dinner', Flag::INCLUDE, FlagCategory::STORY],
        47 => ['met_ioan_d4_am', Flag::INCLUDE, FlagCategory::STORY],
        48 => ['i_o_a_northbrook', Flag::INCLUDE, FlagCategory::STORY],
        51 => ['spent_night_w_sergi', Flag::INCLUDE, FlagCategory::STORY],
        52 => ['sergi_wants_to_go_back', Flag::INCLUDE, FlagCategory::STORY],
        170 => ['aff_roddy', Flag::INCLUDE, FlagCategory::STORY],
        171 => ['aff_ioan', Flag::INCLUDE, FlagCategory::STORY],
        172 => ['aff_greg', Flag::INCLUDE, FlagCategory::STORY],
        173 => ['aff_sergi', Flag::INCLUDE, FlagCategory::STORY],
        174 => ['aff_dag', Flag::INCLUDE, FlagCategory::STORY],
        175 => ['aff_cornel', Flag::INCLUDE, FlagCategory::STORY],
        176 => ['aff_guillered', Flag::INCLUDE, FlagCategory::STORY],
        180 => ['gem_37564', Flag::INCLUDE, FlagCategory::STORY],
        181 => ['house', Flag::INCLUDE, FlagCategory::STORY],
        199 => ['gem_37564_more_people_ded', Flag::INCLUDE, FlagCategory::STORY],
        200 => ['gem_37564_dad_ded', Flag::INCLUDE, FlagCategory::STORY],
        201 => ['gem_37564_mom_ded', Flag::INCLUDE, FlagCategory::STORY],
        202 => ['gem_37564_brother_ded', Flag::INCLUDE, FlagCategory::STORY],
        203 => ['gem_37564_sister_ded', Flag::INCLUDE, FlagCategory::STORY],
        204 => ['gem_37564_neighbor_girl_ded', Flag::INCLUDE, FlagCategory::STORY],
        205 => ['gem_37564_neighbor_boy_ded', Flag::INCLUDE, FlagCategory::STORY],
        206 => ['gem_37564_classmate_0_ded', Flag::INCLUDE, FlagCategory::STORY],
        207 => ['gem_37564_classmate_1_ded', Flag::INCLUDE, FlagCategory::STORY],
        208 => ['gem_37564_classmate_2_ded', Flag::INCLUDE, FlagCategory::STORY],
        209 => ['gem_37564_classmate_3_ded', Flag::INCLUDE, FlagCategory::STORY],
        211 => ['disp_list', Flag::INCLUDE, FlagCategory::SYSTEM],
        700 => ['cgdisp_page_num', Flag::HINT, FlagCategory::SYSTEM],
        709 => ['has_bgm', Flag::HINT, FlagCategory::SYSTEM],
        720 => ['current_event_id', Flag::INCLUDE, FlagCategory::SYSTEM],
        723 => ['has_bg', Flag::HINT, FlagCategory::SYSTEM],
        756 => ['option_group', Flag::INCLUDE, FlagCategory::SYSTEM],
        762 => ['cutscene_index', Flag::INCLUDE, FlagCategory::SYSTEM],
        763 => ['cutscene_unskippable', Flag::INCLUDE, FlagCategory::SYSTEM],
        765 => ['ctr_cg', Flag::HINT, FlagCategory::SYSTEM], # May not useful since we have len() TODO is it just some temp variable?
        850 => ['has_opt_0', Flag::INCLUDE, FlagCategory::SYSTEM],
        851 => ['has_opt_1', Flag::INCLUDE, FlagCategory::SYSTEM],
        852 => ['has_opt_2', Flag::INCLUDE, FlagCategory::SYSTEM],
        853 => ['has_opt_3', Flag::INCLUDE, FlagCategory::SYSTEM],
        993 => ['typewriter_effect_duration', Flag::HINT, FlagCategory::SYSTEM],
        995 => ['in_event_view_mode', Flag::INCLUDE, FlagCategory::SYSTEM],
        996 => ['performing_transition', Flag::HINT, FlagCategory::SYSTEM],
        998 => ['skipping', Flag::INCLUDE, FlagCategory::SYSTEM],
        970 => ['gem_maturity', Flag::INCLUDE, FlagCategory::STORY],
        990 => ['list_related', Flag::HINT, FlagCategory::SYSTEM], # Purpose unknown
        1004 => ['seen_ending_cutscene', Flag::INCLUDE, FlagCategory::SYSTEM],
        1007 => ['first_run', Flag::INCLUDE, FlagCategory::SYSTEM],
        1008 => ['clear_r0', Flag::INCLUDE, FlagCategory::STORY],
        1009 => ['clear_r2', Flag::INCLUDE, FlagCategory::STORY],
        1010 => ['clear_r3', Flag::INCLUDE, FlagCategory::STORY],
        1011 => ['blickwinkel', Flag::INCLUDE, FlagCategory::STORY],
        1012 => ['unlock_r0_roddy', Flag::INCLUDE, FlagCategory::STORY],
        1013 => ['seen_leesha', Flag::INCLUDE, FlagCategory::STORY],
        1014 => ['clear_r0_ioan', Flag::INCLUDE, FlagCategory::STORY],
        1015 => ['re_welcome_to_laughter_land', Flag::INCLUDE, FlagCategory::STORY],
        1100 => ['unlock_gallery_a0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1101 => ['unlock_gallery_a1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1102 => ['unlock_gallery_a2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1103 => ['unlock_gallery_a3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1104 => ['unlock_gallery_a4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1105 => ['unlock_gallery_a5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1106 => ['unlock_gallery_a6', Flag::INCLUDE, FlagCategory::UNLOCK],
        1107 => ['unlock_gallery_a7', Flag::INCLUDE, FlagCategory::UNLOCK],
        1108 => ['unlock_gallery_a8', Flag::INCLUDE, FlagCategory::UNLOCK],
        1109 => ['unlock_gallery_a9', Flag::INCLUDE, FlagCategory::UNLOCK],
        1110 => ['unlock_gallery_a10', Flag::INCLUDE, FlagCategory::UNLOCK],
        1111 => ['unlock_gallery_a11', Flag::INCLUDE, FlagCategory::UNLOCK],
        1112 => ['unlock_gallery_b0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1113 => ['unlock_gallery_b1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1114 => ['unlock_gallery_b2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1115 => ['unlock_gallery_b3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1116 => ['unlock_gallery_b4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1117 => ['unlock_gallery_b5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1118 => ['unlock_gallery_b6', Flag::INCLUDE, FlagCategory::UNLOCK],
        1119 => ['unlock_gallery_b7', Flag::INCLUDE, FlagCategory::UNLOCK],
        1120 => ['unlock_gallery_b8', Flag::INCLUDE, FlagCategory::UNLOCK],
        1121 => ['unlock_gallery_b9', Flag::INCLUDE, FlagCategory::UNLOCK],
        1122 => ['unlock_gallery_b10', Flag::INCLUDE, FlagCategory::UNLOCK],
        1123 => ['unlock_gallery_b11', Flag::INCLUDE, FlagCategory::UNLOCK],
        1124 => ['unlock_gallery_c0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1125 => ['unlock_gallery_c1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1126 => ['unlock_gallery_c2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1127 => ['unlock_gallery_c3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1128 => ['unlock_gallery_c4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1129 => ['unlock_gallery_c5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1130 => ['unlock_gallery_c6', Flag::INCLUDE, FlagCategory::UNLOCK],
        1131 => ['unlock_gallery_c7', Flag::INCLUDE, FlagCategory::UNLOCK],
        1132 => ['unlock_gallery_c8', Flag::INCLUDE, FlagCategory::UNLOCK],
        1133 => ['unlock_gallery_c9', Flag::INCLUDE, FlagCategory::UNLOCK],
        1134 => ['unlock_gallery_c10', Flag::INCLUDE, FlagCategory::UNLOCK],
        1135 => ['unlock_gallery_c11', Flag::INCLUDE, FlagCategory::UNLOCK],
        1136 => ['unlock_gallery_d0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1137 => ['unlock_gallery_d1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1138 => ['unlock_gallery_d2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1139 => ['unlock_gallery_d3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1140 => ['unlock_gallery_d4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1141 => ['unlock_gallery_d5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1142 => ['unlock_gallery_d6', Flag::INCLUDE, FlagCategory::UNLOCK],
        1143 => ['unlock_gallery_d7', Flag::INCLUDE, FlagCategory::UNLOCK],
        1144 => ['unlock_gallery_d8', Flag::INCLUDE, FlagCategory::UNLOCK],
        1145 => ['unlock_gallery_d9', Flag::INCLUDE, FlagCategory::UNLOCK],
        1146 => ['unlock_gallery_d10', Flag::INCLUDE, FlagCategory::UNLOCK],
        1147 => ['unlock_gallery_d11', Flag::INCLUDE, FlagCategory::UNLOCK],
        1148 => ['unlock_gallery_e0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1149 => ['unlock_gallery_e1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1150 => ['unlock_gallery_e2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1151 => ['unlock_gallery_e3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1152 => ['unlock_gallery_e4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1153 => ['unlock_gallery_e5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1154 => ['unlock_gallery_e6', Flag::INCLUDE, FlagCategory::UNLOCK],
        1155 => ['unlock_gallery_e7', Flag::INCLUDE, FlagCategory::UNLOCK],
        1156 => ['unlock_gallery_e8', Flag::INCLUDE, FlagCategory::UNLOCK],
        1157 => ['unlock_gallery_e9', Flag::INCLUDE, FlagCategory::UNLOCK],
        1158 => ['unlock_gallery_e10', Flag::INCLUDE, FlagCategory::UNLOCK],
        1159 => ['unlock_gallery_e11', Flag::INCLUDE, FlagCategory::UNLOCK],
        1160 => ['unlock_gallery_f0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1161 => ['unlock_gallery_f1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1162 => ['unlock_gallery_f2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1163 => ['unlock_gallery_f3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1164 => ['unlock_gallery_f4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1165 => ['unlock_gallery_f5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1166 => ['unlock_gallery_f6', Flag::INCLUDE, FlagCategory::UNLOCK],
        1167 => ['unlock_gallery_f7', Flag::INCLUDE, FlagCategory::UNLOCK],
        1168 => ['unlock_gallery_f8', Flag::INCLUDE, FlagCategory::UNLOCK],
        1169 => ['unlock_gallery_f9', Flag::INCLUDE, FlagCategory::UNLOCK],
        1170 => ['unlock_gallery_f10', Flag::INCLUDE, FlagCategory::UNLOCK],
        1171 => ['unlock_gallery_f11', Flag::INCLUDE, FlagCategory::UNLOCK],
        1172 => ['unlock_gallery_g0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1173 => ['unlock_gallery_g1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1174 => ['unlock_gallery_g2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1175 => ['unlock_gallery_g3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1176 => ['unlock_gallery_g4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1177 => ['unlock_gallery_g5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1178 => ['unlock_gallery_g6', Flag::INCLUDE, FlagCategory::UNLOCK],
        # Too lazy to document every single one...
        1200 => ['unlock_image_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1201 => ['unlock_image_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1202 => ['unlock_image_2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1203 => ['unlock_image_3', Flag::INCLUDE, FlagCategory::UNLOCK],
        1204 => ['unlock_image_4', Flag::INCLUDE, FlagCategory::UNLOCK],
        1205 => ['unlock_image_5', Flag::INCLUDE, FlagCategory::UNLOCK],
        1206 => ['unlock_image_6', Flag::INCLUDE, FlagCategory::UNLOCK],
        1207 => ['unlock_image_7', Flag::INCLUDE, FlagCategory::UNLOCK],
        1208 => ['unlock_image_8', Flag::INCLUDE, FlagCategory::UNLOCK],
        1209 => ['unlock_image_9', Flag::INCLUDE, FlagCategory::UNLOCK],
        1210 => ['unlock_image_10', Flag::INCLUDE, FlagCategory::UNLOCK],
        1211 => ['unlock_image_11', Flag::INCLUDE, FlagCategory::UNLOCK],
        1212 => ['unlock_image_12', Flag::INCLUDE, FlagCategory::UNLOCK],
        1213 => ['unlock_image_13', Flag::INCLUDE, FlagCategory::UNLOCK],
        1214 => ['unlock_image_14', Flag::INCLUDE, FlagCategory::UNLOCK],
        1215 => ['unlock_image_15', Flag::INCLUDE, FlagCategory::UNLOCK],
        1216 => ['unlock_image_16', Flag::INCLUDE, FlagCategory::UNLOCK],
        1217 => ['unlock_image_17', Flag::INCLUDE, FlagCategory::UNLOCK],
        1218 => ['unlock_image_18', Flag::INCLUDE, FlagCategory::UNLOCK],
        1219 => ['unlock_image_19', Flag::INCLUDE, FlagCategory::UNLOCK],
        1220 => ['unlock_image_20', Flag::INCLUDE, FlagCategory::UNLOCK],
        1221 => ['unlock_image_21', Flag::INCLUDE, FlagCategory::UNLOCK],
        1222 => ['unlock_image_22', Flag::INCLUDE, FlagCategory::UNLOCK],
        1223 => ['unlock_image_23', Flag::INCLUDE, FlagCategory::UNLOCK],
        1224 => ['unlock_image_24', Flag::INCLUDE, FlagCategory::UNLOCK],
        1225 => ['unlock_image_25', Flag::INCLUDE, FlagCategory::UNLOCK],
        1226 => ['unlock_image_26', Flag::INCLUDE, FlagCategory::UNLOCK],
        1227 => ['unlock_image_27', Flag::INCLUDE, FlagCategory::UNLOCK],
        1228 => ['unlock_image_28', Flag::INCLUDE, FlagCategory::UNLOCK],
        1229 => ['unlock_image_29', Flag::INCLUDE, FlagCategory::UNLOCK],
        1230 => ['unlock_image_30', Flag::INCLUDE, FlagCategory::UNLOCK],
        1231 => ['unlock_image_31', Flag::INCLUDE, FlagCategory::UNLOCK],
        1232 => ['unlock_image_32', Flag::INCLUDE, FlagCategory::UNLOCK],
        1233 => ['unlock_image_33', Flag::INCLUDE, FlagCategory::UNLOCK],
        1234 => ['unlock_image_34', Flag::INCLUDE, FlagCategory::UNLOCK],
        1235 => ['unlock_image_35', Flag::INCLUDE, FlagCategory::UNLOCK],
        1236 => ['unlock_image_36', Flag::INCLUDE, FlagCategory::UNLOCK],
        1237 => ['unlock_image_37', Flag::INCLUDE, FlagCategory::UNLOCK],
        1238 => ['unlock_image_38', Flag::INCLUDE, FlagCategory::UNLOCK],
        1239 => ['unlock_image_39', Flag::INCLUDE, FlagCategory::UNLOCK],
        1240 => ['unlock_image_40', Flag::INCLUDE, FlagCategory::UNLOCK],
        1241 => ['unlock_image_41', Flag::INCLUDE, FlagCategory::UNLOCK],
        1242 => ['unlock_image_42', Flag::INCLUDE, FlagCategory::UNLOCK],
        1243 => ['unlock_image_43', Flag::INCLUDE, FlagCategory::UNLOCK],
        1244 => ['unlock_image_44', Flag::INCLUDE, FlagCategory::UNLOCK],
        1245 => ['unlock_image_45', Flag::INCLUDE, FlagCategory::UNLOCK],
        1246 => ['unlock_image_46', Flag::INCLUDE, FlagCategory::UNLOCK],
        1247 => ['unlock_image_47', Flag::INCLUDE, FlagCategory::UNLOCK],
        1248 => ['unlock_image_48', Flag::INCLUDE, FlagCategory::UNLOCK],
        1249 => ['unlock_image_49', Flag::INCLUDE, FlagCategory::UNLOCK],
        1250 => ['unlock_image_50', Flag::INCLUDE, FlagCategory::UNLOCK],
        1251 => ['unlock_image_51', Flag::INCLUDE, FlagCategory::UNLOCK],
        1252 => ['unlock_image_52', Flag::INCLUDE, FlagCategory::UNLOCK],
        1253 => ['unlock_image_53', Flag::INCLUDE, FlagCategory::UNLOCK],
        1254 => ['unlock_image_54', Flag::INCLUDE, FlagCategory::UNLOCK],
        1255 => ['unlock_image_55', Flag::INCLUDE, FlagCategory::UNLOCK],
        1256 => ['unlock_image_56', Flag::INCLUDE, FlagCategory::UNLOCK],
        1257 => ['unlock_image_57', Flag::INCLUDE, FlagCategory::UNLOCK],
        1258 => ['unlock_image_58', Flag::INCLUDE, FlagCategory::UNLOCK],
        1259 => ['unlock_image_59', Flag::INCLUDE, FlagCategory::UNLOCK],
        1260 => ['unlock_image_60', Flag::INCLUDE, FlagCategory::UNLOCK],
        1261 => ['unlock_image_61', Flag::INCLUDE, FlagCategory::UNLOCK],
        1262 => ['unlock_image_62', Flag::INCLUDE, FlagCategory::UNLOCK],
        1263 => ['unlock_image_63', Flag::INCLUDE, FlagCategory::UNLOCK],
        1264 => ['unlock_image_64', Flag::INCLUDE, FlagCategory::UNLOCK],
        1265 => ['unlock_image_65', Flag::INCLUDE, FlagCategory::UNLOCK],
        1266 => ['unlock_image_66', Flag::INCLUDE, FlagCategory::UNLOCK],
        1267 => ['unlock_image_67', Flag::INCLUDE, FlagCategory::UNLOCK],
        1268 => ['unlock_image_68', Flag::INCLUDE, FlagCategory::UNLOCK],
        1269 => ['unlock_image_69', Flag::INCLUDE, FlagCategory::UNLOCK],
        1270 => ['unlock_image_70', Flag::INCLUDE, FlagCategory::UNLOCK],
        1271 => ['unlock_image_71', Flag::INCLUDE, FlagCategory::UNLOCK],
        1272 => ['unlock_image_72', Flag::INCLUDE, FlagCategory::UNLOCK],
        1273 => ['unlock_image_73', Flag::INCLUDE, FlagCategory::UNLOCK],
        1274 => ['unlock_image_74', Flag::INCLUDE, FlagCategory::UNLOCK],
        1275 => ['unlock_image_75', Flag::INCLUDE, FlagCategory::UNLOCK],
        1276 => ['unlock_image_76', Flag::INCLUDE, FlagCategory::UNLOCK],
        1277 => ['unlock_image_77', Flag::INCLUDE, FlagCategory::UNLOCK],
        1278 => ['unlock_image_78', Flag::INCLUDE, FlagCategory::UNLOCK],
        1279 => ['unlock_image_79', Flag::INCLUDE, FlagCategory::UNLOCK],
        1280 => ['unlock_image_80', Flag::INCLUDE, FlagCategory::UNLOCK],
        1281 => ['unlock_image_81', Flag::INCLUDE, FlagCategory::UNLOCK],
        1282 => ['unlock_image_82', Flag::INCLUDE, FlagCategory::UNLOCK],
        1283 => ['unlock_image_83', Flag::INCLUDE, FlagCategory::UNLOCK],
        1284 => ['unlock_image_84', Flag::INCLUDE, FlagCategory::UNLOCK],
        1285 => ['unlock_image_85', Flag::INCLUDE, FlagCategory::UNLOCK],
        1286 => ['unlock_image_86', Flag::INCLUDE, FlagCategory::UNLOCK],
        1287 => ['unlock_image_87', Flag::INCLUDE, FlagCategory::UNLOCK],
        1288 => ['unlock_image_88', Flag::INCLUDE, FlagCategory::UNLOCK],
        1289 => ['unlock_image_89', Flag::INCLUDE, FlagCategory::UNLOCK],
        1290 => ['unlock_image_90', Flag::INCLUDE, FlagCategory::UNLOCK],
        1291 => ['unlock_image_91', Flag::INCLUDE, FlagCategory::UNLOCK],
        1292 => ['unlock_image_92', Flag::INCLUDE, FlagCategory::UNLOCK],
        1293 => ['unlock_image_93', Flag::INCLUDE, FlagCategory::UNLOCK],
        1294 => ['unlock_image_94', Flag::INCLUDE, FlagCategory::UNLOCK],
        1295 => ['unlock_image_95', Flag::INCLUDE, FlagCategory::UNLOCK],
        1296 => ['unlock_image_96', Flag::INCLUDE, FlagCategory::UNLOCK],
        1297 => ['unlock_image_97', Flag::INCLUDE, FlagCategory::UNLOCK],
        1298 => ['unlock_image_98', Flag::INCLUDE, FlagCategory::UNLOCK],
        1299 => ['unlock_image_99', Flag::INCLUDE, FlagCategory::UNLOCK],
        1300 => ['unlock_image_100', Flag::INCLUDE, FlagCategory::UNLOCK],
        1301 => ['unlock_image_101', Flag::INCLUDE, FlagCategory::UNLOCK],
        1302 => ['unlock_image_102', Flag::INCLUDE, FlagCategory::UNLOCK],
        1303 => ['unlock_image_103', Flag::INCLUDE, FlagCategory::UNLOCK],
        1304 => ['unlock_image_104', Flag::INCLUDE, FlagCategory::UNLOCK],
        1305 => ['unlock_image_105', Flag::INCLUDE, FlagCategory::UNLOCK],
        1306 => ['unlock_image_106', Flag::INCLUDE, FlagCategory::UNLOCK],
        1307 => ['unlock_image_107', Flag::INCLUDE, FlagCategory::UNLOCK],
        1308 => ['unlock_image_108', Flag::INCLUDE, FlagCategory::UNLOCK],
        1309 => ['unlock_image_109', Flag::INCLUDE, FlagCategory::UNLOCK],
        1310 => ['unlock_image_110', Flag::INCLUDE, FlagCategory::UNLOCK],
        1311 => ['unlock_image_111', Flag::INCLUDE, FlagCategory::UNLOCK],
        1312 => ['unlock_image_112', Flag::INCLUDE, FlagCategory::UNLOCK],
        1313 => ['unlock_image_113', Flag::INCLUDE, FlagCategory::UNLOCK],
        1314 => ['unlock_image_114', Flag::INCLUDE, FlagCategory::UNLOCK],
        1315 => ['unlock_image_115', Flag::INCLUDE, FlagCategory::UNLOCK],
        1316 => ['unlock_image_116', Flag::INCLUDE, FlagCategory::UNLOCK],
        1317 => ['unlock_image_117', Flag::INCLUDE, FlagCategory::UNLOCK],
        1318 => ['unlock_image_118', Flag::INCLUDE, FlagCategory::UNLOCK],
        1319 => ['unlock_image_119', Flag::INCLUDE, FlagCategory::UNLOCK],
        1320 => ['unlock_image_120', Flag::INCLUDE, FlagCategory::UNLOCK],
        1321 => ['unlock_image_121', Flag::INCLUDE, FlagCategory::UNLOCK],
        1322 => ['unlock_image_122', Flag::INCLUDE, FlagCategory::UNLOCK],
        1323 => ['unlock_image_123', Flag::INCLUDE, FlagCategory::UNLOCK],
        1324 => ['unlock_image_124', Flag::INCLUDE, FlagCategory::UNLOCK],
        1325 => ['unlock_image_125', Flag::INCLUDE, FlagCategory::UNLOCK],
        1326 => ['unlock_image_126', Flag::INCLUDE, FlagCategory::UNLOCK],
        1327 => ['unlock_image_127', Flag::INCLUDE, FlagCategory::UNLOCK],
        1328 => ['unlock_image_128', Flag::INCLUDE, FlagCategory::UNLOCK],
        1329 => ['unlock_image_129', Flag::INCLUDE, FlagCategory::UNLOCK],
        1330 => ['unlock_image_130', Flag::INCLUDE, FlagCategory::UNLOCK],
        1331 => ['unlock_image_131', Flag::INCLUDE, FlagCategory::UNLOCK],
        1332 => ['unlock_image_132', Flag::INCLUDE, FlagCategory::UNLOCK],
        1333 => ['unlock_image_133', Flag::INCLUDE, FlagCategory::UNLOCK],
        1334 => ['unlock_image_134', Flag::INCLUDE, FlagCategory::UNLOCK],
        1335 => ['unlock_image_135', Flag::INCLUDE, FlagCategory::UNLOCK],
        1336 => ['unlock_image_136', Flag::INCLUDE, FlagCategory::UNLOCK],
        1337 => ['unlock_image_137', Flag::INCLUDE, FlagCategory::UNLOCK],
        1338 => ['unlock_image_138', Flag::INCLUDE, FlagCategory::UNLOCK],
        1339 => ['unlock_image_139', Flag::INCLUDE, FlagCategory::UNLOCK],
        1340 => ['unlock_image_140', Flag::INCLUDE, FlagCategory::UNLOCK],
        1341 => ['unlock_image_141', Flag::INCLUDE, FlagCategory::UNLOCK],
        1342 => ['unlock_image_142', Flag::INCLUDE, FlagCategory::UNLOCK],
        1343 => ['unlock_image_143', Flag::INCLUDE, FlagCategory::UNLOCK],
        1344 => ['unlock_image_144', Flag::INCLUDE, FlagCategory::UNLOCK],
        1345 => ['unlock_image_145', Flag::INCLUDE, FlagCategory::UNLOCK],
        1346 => ['unlock_image_146', Flag::INCLUDE, FlagCategory::UNLOCK],
        1347 => ['unlock_image_147', Flag::INCLUDE, FlagCategory::UNLOCK],
        1348 => ['unlock_image_148', Flag::INCLUDE, FlagCategory::UNLOCK],
        1349 => ['unlock_image_149', Flag::INCLUDE, FlagCategory::UNLOCK],
        1350 => ['unlock_image_150', Flag::INCLUDE, FlagCategory::UNLOCK],
        1351 => ['unlock_image_151', Flag::INCLUDE, FlagCategory::UNLOCK],
        1352 => ['unlock_image_152', Flag::INCLUDE, FlagCategory::UNLOCK],
        1353 => ['unlock_image_153', Flag::INCLUDE, FlagCategory::UNLOCK],
        1354 => ['unlock_image_154', Flag::INCLUDE, FlagCategory::UNLOCK],
        1355 => ['unlock_image_155', Flag::INCLUDE, FlagCategory::UNLOCK],
        1356 => ['unlock_image_156', Flag::INCLUDE, FlagCategory::UNLOCK],
        1357 => ['unlock_image_157', Flag::INCLUDE, FlagCategory::UNLOCK],
        1358 => ['unlock_image_158', Flag::INCLUDE, FlagCategory::UNLOCK],
        1359 => ['unlock_image_159', Flag::INCLUDE, FlagCategory::UNLOCK],
        1360 => ['unlock_image_160', Flag::INCLUDE, FlagCategory::UNLOCK],
        1361 => ['unlock_image_161', Flag::INCLUDE, FlagCategory::UNLOCK],
        1362 => ['unlock_image_162', Flag::INCLUDE, FlagCategory::UNLOCK],
        1363 => ['unlock_image_163', Flag::INCLUDE, FlagCategory::UNLOCK],
        1364 => ['unlock_image_164', Flag::INCLUDE, FlagCategory::UNLOCK],
        1365 => ['unlock_image_165', Flag::INCLUDE, FlagCategory::UNLOCK],
        1366 => ['unlock_image_166', Flag::INCLUDE, FlagCategory::UNLOCK],
        1367 => ['unlock_image_167', Flag::INCLUDE, FlagCategory::UNLOCK],
        1430 => ['unlock_replay_ioan_end_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1431 => ['unlock_replay_ioan_end_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1432 => ['unlock_replay_ioan_end_2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1433 => ['unlock_replay_roddy_end_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1434 => ['unlock_replay_roddy_end_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1435 => ['unlock_replay_dick_torture_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1436 => ['unlock_replay_dick_torture_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1437 => ['unlock_replay_dick_torture_2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1438 => ['unlock_replay_dag_end_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1439 => ['unlock_replay_dag_end_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1440 => ['unlock_replay_sergi_end_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1441 => ['unlock_replay_sergi_end_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1442 => ['unlock_replay_cornel_encounter', Flag::INCLUDE, FlagCategory::UNLOCK],
        1443 => ['unlock_replay_cornel_end_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1444 => ['unlock_replay_cornel_end_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1445 => ['unlock_replay_cornel_end_2', Flag::INCLUDE, FlagCategory::UNLOCK],
        1446 => ['unlock_replay_greg_end_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1447 => ['unlock_replay_greg_end_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1448 => ['unlock_replay_greg_end_encore', Flag::INCLUDE, FlagCategory::UNLOCK],
        1449 => ['unlock_replay_guillered_fj', Flag::INCLUDE, FlagCategory::UNLOCK],
        1450 => ['unlock_replay_guillered_end_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1451 => ['unlock_replay_guillered_end_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        1452 => ['unlock_replay_cornel_torture', Flag::INCLUDE, FlagCategory::UNLOCK],
        1453 => ['unlock_replay_aby_torture_0', Flag::INCLUDE, FlagCategory::UNLOCK],
        1454 => ['unlock_replay_aby_torture_1', Flag::INCLUDE, FlagCategory::UNLOCK],
        10007 => ['system_keycode', Flag::HINT, FlagCategory::SYSTEM],
    }
end
