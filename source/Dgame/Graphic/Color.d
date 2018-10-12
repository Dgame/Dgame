/*
 *******************************************************************************************
 * Dgame (a D game framework) - Copyright (c) Randy Schütt
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim
 *    that you wrote the original software. If you use this software in a product,
 *    an acknowledgment in the product documentation would be appreciated but is
 *    not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution.
 *******************************************************************************************
 */
module Dgame.Graphic.Color;

private:

import derelict.sdl2.types;

package(Dgame):

static struct Colors(T) {
    static immutable T Aliceblue            = T(240, 248, 255);
    static immutable T Antiquewhite         = T(250, 235, 215);
    static immutable T Antiquewhite1        = T(255, 239, 219);
    static immutable T Antiquewhite2        = T(238, 223, 204);
    static immutable T Antiquewhite3        = T(205, 192, 176);
    static immutable T Antiquewhite4        = T(139, 131, 120);
    static immutable T Aquamarine           = T(127, 255, 212);
    static immutable T Aquamarine1          = T(127, 255, 212);
    static immutable T Aquamarine2          = T(118, 238, 198);
    static immutable T Aquamarine3          = T(102, 205, 170);
    static immutable T Aquamarine4          = T( 69, 139, 116);
    static immutable T Azure                = T(240, 255, 255);
    static immutable T Azure1               = T(240, 255, 255);
    static immutable T Azure2               = T(224, 238, 238);
    static immutable T Azure3               = T(193, 205, 205);
    static immutable T Azure4               = T(131, 139, 139);
    static immutable T Beige                = T(245, 245, 220);
    static immutable T Bisque               = T(255, 228, 196);
    static immutable T Bisque1              = T(255, 228, 196);
    static immutable T Bisque2              = T(238, 213, 183);
    static immutable T Bisque3              = T(205, 183, 158);
    static immutable T Bisque4              = T(139, 125, 107);
    static immutable T Black                = T(  0,   0,   0);
    static immutable T Blanchedalmond       = T(255, 235, 205);
    static immutable T Blue                 = T(  0,   0, 255);
    static immutable T Blue1                = T(  0,   0, 255);
    static immutable T Blue2                = T(  0,   0, 238);
    static immutable T Blue3                = T(  0,   0, 205);
    static immutable T Blue4                = T(  0,   0, 139);
    static immutable T Blueviolet           = T(138,  43, 226);
    static immutable T Brown                = T(165,  42,  42);
    static immutable T Brown1               = T(255,  64,  64);
    static immutable T Brown2               = T(238,  59,  59);
    static immutable T Brown3               = T(205,  51,  51);
    static immutable T Brown4               = T(139,  35,  35);
    static immutable T Burlywood            = T(222, 184, 135);
    static immutable T Burlywood1           = T(255, 211, 155);
    static immutable T Burlywood2           = T(238, 197, 145);
    static immutable T Burlywood3           = T(205, 170, 125);
    static immutable T Burlywood4           = T(139, 115,  85);
    static immutable T Cadetblue            = T( 95, 158, 160);
    static immutable T Cadetblue1           = T(152, 245, 255);
    static immutable T Cadetblue2           = T(142, 229, 238);
    static immutable T Cadetblue3           = T(122, 197, 205);
    static immutable T Cadetblue4           = T( 83, 134, 139);
    static immutable T Chartreuse           = T(127, 255,   0);
    static immutable T Chartreuse1          = T(127, 255,   0);
    static immutable T Chartreuse2          = T(118, 238,   0);
    static immutable T Chartreuse3          = T(102, 205,   0);
    static immutable T Chartreuse4          = T( 69, 139,   0);
    static immutable T Chocolate            = T(210, 105,  30);
    static immutable T Chocolate1           = T(255, 127,  36);
    static immutable T Chocolate2           = T(238, 118,  33);
    static immutable T Chocolate3           = T(205, 102,  29);
    static immutable T Chocolate4           = T(139,  69,  19);
    static immutable T Coral                = T(255, 127,  80);
    static immutable T Coral1               = T(255, 114,  86);
    static immutable T Coral2               = T(238, 106,  80);
    static immutable T Coral3               = T(205,  91,  69);
    static immutable T Coral4               = T(139,  62,  47);
    static immutable T Cornflowerblue       = T(100, 149, 237);
    static immutable T Cornsilk             = T(255, 248, 220);
    static immutable T Cornsilk1            = T(255, 248, 220);
    static immutable T Cornsilk2            = T(238, 232, 205);
    static immutable T Cornsilk3            = T(205, 200, 177);
    static immutable T Cornsilk4            = T(139, 136, 120);
    static immutable T Cyan                 = T(  0, 255, 255);
    static immutable T Cyan1                = T(  0, 255, 255);
    static immutable T Cyan2                = T(  0, 238, 238);
    static immutable T Cyan3                = T(  0, 205, 205);
    static immutable T Cyan4                = T(  0, 139, 139);
    static immutable T Darkblue             = T(  0,   0, 139);
    static immutable T Darkcyan             = T(  0, 139, 139);
    static immutable T Darkgoldenrod        = T(184, 134,  11);
    static immutable T Darkgoldenrod1       = T(255, 185,  15);
    static immutable T Darkgoldenrod2       = T(238, 173,  14);
    static immutable T Darkgoldenrod3       = T(205, 149,  12);
    static immutable T Darkgoldenrod4       = T(139, 101,   8);
    static immutable T Darkgray             = T(169, 169, 169);
    static immutable T Darkgreen            = T(  0, 100,   0);
    static immutable T Darkgrey             = T(169, 169, 169);
    static immutable T Darkkhaki            = T(189, 183, 107);
    static immutable T Darkmagenta          = T(139,   0, 139);
    static immutable T Darkolivegreen       = T( 85, 107,  47);
    static immutable T Darkolivegreen1      = T(202, 255, 112);
    static immutable T Darkolivegreen2      = T(188, 238, 104);
    static immutable T Darkolivegreen3      = T(162, 205,  90);
    static immutable T Darkolivegreen4      = T(110, 139,  61);
    static immutable T Darkorange           = T(255, 140,   0);
    static immutable T Darkorange1          = T(255, 127,   0);
    static immutable T Darkorange2          = T(238, 118,   0);
    static immutable T Darkorange3          = T(205, 102,   0);
    static immutable T Darkorange4          = T(139,  69,   0);
    static immutable T Darkorchid           = T(153,  50, 204);
    static immutable T Darkorchid1          = T(191,  62, 255);
    static immutable T Darkorchid2          = T(178,  58, 238);
    static immutable T Darkorchid3          = T(154,  50, 205);
    static immutable T Darkorchid4          = T(104,  34, 139);
    static immutable T Darkred              = T(139,   0,   0);
    static immutable T Darksalmon           = T(233, 150, 122);
    static immutable T Darkseagreen         = T(143, 188, 143);
    static immutable T Darkseagreen1        = T(193, 255, 193);
    static immutable T Darkseagreen2        = T(180, 238, 180);
    static immutable T Darkseagreen3        = T(155, 205, 155);
    static immutable T Darkseagreen4        = T(105, 139, 105);
    static immutable T Darkslateblue        = T( 72,  61, 139);
    static immutable T Darkslategray        = T( 47,  79,  79);
    static immutable T Darkslategray1       = T(151, 255, 255);
    static immutable T Darkslategray2       = T(141, 238, 238);
    static immutable T Darkslategray3       = T(121, 205, 205);
    static immutable T Darkslategray4       = T( 82, 139, 139);
    static immutable T Darkslategrey        = T( 47,  79,  79);
    static immutable T Darkturquoise        = T(  0, 206, 209);
    static immutable T Darkviolet           = T(148,   0, 211);
    static immutable T Deeppink             = T(255,  20, 147);
    static immutable T Deeppink1            = T(255,  20, 147);
    static immutable T Deeppink2            = T(238,  18, 137);
    static immutable T Deeppink3            = T(205,  16, 118);
    static immutable T Deeppink4            = T(139,  10,  80);
    static immutable T Deepskyblue          = T(  0, 191, 255);
    static immutable T Deepskyblue1         = T(  0, 191, 255);
    static immutable T Deepskyblue2         = T(  0, 178, 238);
    static immutable T Deepskyblue3         = T(  0, 154, 205);
    static immutable T Deepskyblue4         = T(  0, 104, 139);
    static immutable T Dimgray              = T(105, 105, 105);
    static immutable T Dimgrey              = T(105, 105, 105);
    static immutable T Dodgerblue           = T( 30, 144, 255);
    static immutable T Dodgerblue1          = T( 30, 144, 255);
    static immutable T Dodgerblue2          = T( 28, 134, 238);
    static immutable T Dodgerblue3          = T( 24, 116, 205);
    static immutable T Dodgerblue4          = T( 16,  78, 139);
    static immutable T Firebrick            = T(178,  34,  34);
    static immutable T Firebrick1           = T(255,  48,  48);
    static immutable T Firebrick2           = T(238,  44,  44);
    static immutable T Firebrick3           = T(205,  38,  38);
    static immutable T Firebrick4           = T(139,  26,  26);
    static immutable T Floralwhite          = T(255, 250, 240);
    static immutable T Forestgreen          = T( 34, 139,  34);
    static immutable T Gainsboro            = T(220, 220, 220);
    static immutable T Ghostwhite           = T(248, 248, 255);
    static immutable T Gold                 = T(255, 215,   0);
    static immutable T Gold1                = T(255, 215,   0);
    static immutable T Gold2                = T(238, 201,   0);
    static immutable T Gold3                = T(205, 173,   0);
    static immutable T Gold4                = T(139, 117,   0);
    static immutable T Goldenrod            = T(218, 165,  32);
    static immutable T Goldenrod1           = T(255, 193,  37);
    static immutable T Goldenrod2           = T(238, 180,  34);
    static immutable T Goldenrod3           = T(205, 155,  29);
    static immutable T Goldenrod4           = T(139, 105,  20);
    static immutable T Green                = T(  0, 255,   0);
    static immutable T Green1               = T(  0, 255,   0);
    static immutable T Green2               = T(  0, 238,   0);
    static immutable T Green3               = T(  0, 205,   0);
    static immutable T Green4               = T(  0, 139,   0);
    static immutable T Greenyellow          = T(173, 255,  47);
    static immutable T Honeydew             = T(240, 255, 240);
    static immutable T Honeydew1            = T(240, 255, 240);
    static immutable T Honeydew2            = T(224, 238, 224);
    static immutable T Honeydew3            = T(193, 205, 193);
    static immutable T Honeydew4            = T(131, 139, 131);
    static immutable T Hotpink              = T(255, 105, 180);
    static immutable T Hotpink1             = T(255, 110, 180);
    static immutable T Hotpink2             = T(238, 106, 167);
    static immutable T Hotpink3             = T(205,  96, 144);
    static immutable T Hotpink4             = T(139,  58,  98);
    static immutable T Indianred            = T(205,  92,  92);
    static immutable T Indianred1           = T(255, 106, 106);
    static immutable T Indianred2           = T(238,  99,  99);
    static immutable T Indianred3           = T(205,  85,  85);
    static immutable T Indianred4           = T(139,  58,  58);
    static immutable T Ivory                = T(255, 255, 240);
    static immutable T Ivory1               = T(255, 255, 240);
    static immutable T Ivory2               = T(238, 238, 224);
    static immutable T Ivory3               = T(205, 205, 193);
    static immutable T Ivory4               = T(139, 139, 131);
    static immutable T Khaki                = T(240, 230, 140);
    static immutable T Khaki1               = T(255, 246, 143);
    static immutable T Khaki2               = T(238, 230, 133);
    static immutable T Khaki3               = T(205, 198, 115);
    static immutable T Khaki4               = T(139, 134,  78);
    static immutable T Lavender             = T(230, 230, 250);
    static immutable T Lavenderblush        = T(255, 240, 245);
    static immutable T Lavenderblush1       = T(255, 240, 245);
    static immutable T Lavenderblush2       = T(238, 224, 229);
    static immutable T Lavenderblush3       = T(205, 193, 197);
    static immutable T Lavenderblush4       = T(139, 131, 134);
    static immutable T Lawngreen            = T(124, 252,   0);
    static immutable T Lemonchiffon         = T(255, 250, 205);
    static immutable T Lemonchiffon1        = T(255, 250, 205);
    static immutable T Lemonchiffon2        = T(238, 233, 191);
    static immutable T Lemonchiffon3        = T(205, 201, 165);
    static immutable T Lemonchiffon4        = T(139, 137, 112);
    static immutable T Lightblue            = T(173, 216, 230);
    static immutable T Lightblue1           = T(191, 239, 255);
    static immutable T Lightblue2           = T(178, 223, 238);
    static immutable T Lightblue3           = T(154, 192, 205);
    static immutable T Lightblue4           = T(104, 131, 139);
    static immutable T Lightcoral           = T(240, 128, 128);
    static immutable T Lightcyan            = T(224, 255, 255);
    static immutable T Lightcyan1           = T(224, 255, 255);
    static immutable T Lightcyan2           = T(209, 238, 238);
    static immutable T Lightcyan3           = T(180, 205, 205);
    static immutable T Lightcyan4           = T(122, 139, 139);
    static immutable T Lightgoldenrod       = T(238, 221, 130);
    static immutable T Lightgoldenrod1      = T(255, 236, 139);
    static immutable T Lightgoldenrod2      = T(238, 220, 130);
    static immutable T Lightgoldenrod3      = T(205, 190, 112);
    static immutable T Lightgoldenrod4      = T(139, 129,  76);
    static immutable T Lightgoldenrodyellow = T(250, 250, 210);
    static immutable T Lightgray            = T(211, 211, 211);
    static immutable T Lightgreen           = T(144, 238, 144);
    static immutable T Lightgrey            = T(211, 211, 211);
    static immutable T Lightpink            = T(255, 182, 193);
    static immutable T Lightpink1           = T(255, 174, 185);
    static immutable T Lightpink2           = T(238, 162, 173);
    static immutable T Lightpink3           = T(205, 140, 149);
    static immutable T Lightpink4           = T(139,  95, 101);
    static immutable T Lightsalmon          = T(255, 160, 122);
    static immutable T Lightsalmon1         = T(255, 160, 122);
    static immutable T Lightsalmon2         = T(238, 149, 114);
    static immutable T Lightsalmon3         = T(205, 129,  98);
    static immutable T Lightsalmon4         = T(139,  87,  66);
    static immutable T Lightseagreen        = T( 32, 178, 170);
    static immutable T Lightskyblue         = T(135, 206, 250);
    static immutable T Lightskyblue1        = T(176, 226, 255);
    static immutable T Lightskyblue2        = T(164, 211, 238);
    static immutable T Lightskyblue3        = T(141, 182, 205);
    static immutable T Lightskyblue4        = T( 96, 123, 139);
    static immutable T Lightslateblue       = T(132, 112, 255);
    static immutable T Lightslategray       = T(119, 136, 153);
    static immutable T Lightslategrey       = T(119, 136, 153);
    static immutable T Lightsteelblue       = T(176, 196, 222);
    static immutable T Lightsteelblue1      = T(202, 225, 255);
    static immutable T Lightsteelblue2      = T(188, 210, 238);
    static immutable T Lightsteelblue3      = T(162, 181, 205);
    static immutable T Lightsteelblue4      = T(110, 123, 139);
    static immutable T Lightyellow          = T(255, 255, 224);
    static immutable T Lightyellow1         = T(255, 255, 224);
    static immutable T Lightyellow2         = T(238, 238, 209);
    static immutable T Lightyellow3         = T(205, 205, 180);
    static immutable T Lightyellow4         = T(139, 139, 122);
    static immutable T Limegreen            = T( 50, 205,  50);
    static immutable T Linen                = T(250, 240, 230);
    static immutable T Magenta              = T(255,   0, 255);
    static immutable T Magenta1             = T(255,   0, 255);
    static immutable T Magenta2             = T(238,   0, 238);
    static immutable T Magenta3             = T(205,   0, 205);
    static immutable T Magenta4             = T(139,   0, 139);
    static immutable T Maroon               = T(176,  48,  96);
    static immutable T Maroon1              = T(255,  52, 179);
    static immutable T Maroon2              = T(238,  48, 167);
    static immutable T Maroon3              = T(205,  41, 144);
    static immutable T Maroon4              = T(139,  28,  98);
    static immutable T Mediumaquamarine     = T(102, 205, 170);
    static immutable T Mediumblue           = T(  0,   0, 205);
    static immutable T Mediumorchid         = T(186,  85, 211);
    static immutable T Mediumorchid1        = T(224, 102, 255);
    static immutable T Mediumorchid2        = T(209,  95, 238);
    static immutable T Mediumorchid3        = T(180,  82, 205);
    static immutable T Mediumorchid4        = T(122,  55, 139);
    static immutable T Mediumpurple         = T(147, 112, 219);
    static immutable T Mediumpurple1        = T(171, 130, 255);
    static immutable T Mediumpurple2        = T(159, 121, 238);
    static immutable T Mediumpurple3        = T(137, 104, 205);
    static immutable T Mediumpurple4        = T( 93,  71, 139);
    static immutable T Mediumseagreen       = T( 60, 179, 113);
    static immutable T Mediumslateblue      = T(123, 104, 238);
    static immutable T Mediumspringgreen    = T(  0, 250, 154);
    static immutable T Mediumturquoise      = T( 72, 209, 204);
    static immutable T Mediumvioletred      = T(199,  21, 133);
    static immutable T Midnightblue         = T( 25,  25, 112);
    static immutable T Mintcream            = T(245, 255, 250);
    static immutable T Mistyrose            = T(255, 228, 225);
    static immutable T Mistyrose1           = T(255, 228, 225);
    static immutable T Mistyrose2           = T(238, 213, 210);
    static immutable T Mistyrose3           = T(205, 183, 181);
    static immutable T Mistyrose4           = T(139, 125, 123);
    static immutable T Moccasin             = T(255, 228, 181);
    static immutable T Navajowhite          = T(255, 222, 173);
    static immutable T Navajowhite1         = T(255, 222, 173);
    static immutable T Navajowhite2         = T(238, 207, 161);
    static immutable T Navajowhite3         = T(205, 179, 139);
    static immutable T Navajowhite4         = T(139, 121,  94);
    static immutable T Navy                 = T(  0,   0, 128);
    static immutable T Navyblue             = T(  0,   0, 128);
    static immutable T Oldlace              = T(253, 245, 230);
    static immutable T Olivedrab            = T(107, 142,  35);
    static immutable T Olivedrab1           = T(192, 255,  62);
    static immutable T Olivedrab2           = T(179, 238,  58);
    static immutable T Olivedrab3           = T(154, 205,  50);
    static immutable T Olivedrab4           = T(105, 139,  34);
    static immutable T Orange               = T(255, 165,   0);
    static immutable T Orange1              = T(255, 165,   0);
    static immutable T Orange2              = T(238, 154,   0);
    static immutable T Orange3              = T(205, 133,   0);
    static immutable T Orange4              = T(139,  90,   0);
    static immutable T Orangered            = T(255,  69,   0);
    static immutable T Orangered1           = T(255,  69,   0);
    static immutable T Orangered2           = T(238,  64,   0);
    static immutable T Orangered3           = T(205,  55,   0);
    static immutable T Orangered4           = T(139,  37,   0);
    static immutable T Orchid               = T(218, 112, 214);
    static immutable T Orchid1              = T(255, 131, 250);
    static immutable T Orchid2              = T(238, 122, 233);
    static immutable T Orchid3              = T(205, 105, 201);
    static immutable T Orchid4              = T(139,  71, 137);
    static immutable T Palegoldenrod        = T(238, 232, 170);
    static immutable T Palegreen            = T(152, 251, 152);
    static immutable T Palegreen1           = T(154, 255, 154);
    static immutable T Palegreen2           = T(144, 238, 144);
    static immutable T Palegreen3           = T(124, 205, 124);
    static immutable T Palegreen4           = T( 84, 139,  84);
    static immutable T Paleturquoise        = T(175, 238, 238);
    static immutable T Paleturquoise1       = T(187, 255, 255);
    static immutable T Paleturquoise2       = T(174, 238, 238);
    static immutable T Paleturquoise3       = T(150, 205, 205);
    static immutable T Paleturquoise4       = T(102, 139, 139);
    static immutable T Palevioletred        = T(219, 112, 147);
    static immutable T Palevioletred1       = T(255, 130, 171);
    static immutable T Palevioletred2       = T(238, 121, 159);
    static immutable T Palevioletred3       = T(205, 104, 137);
    static immutable T Palevioletred4       = T(139,  71,  93);
    static immutable T Papayawhip           = T(255, 239, 213);
    static immutable T Peachpuff            = T(255, 218, 185);
    static immutable T Peachpuff1           = T(255, 218, 185);
    static immutable T Peachpuff2           = T(238, 203, 173);
    static immutable T Peachpuff3           = T(205, 175, 149);
    static immutable T Peachpuff4           = T(139, 119, 101);
    static immutable T Peru                 = T(205, 133,  63);
    static immutable T Pink                 = T(255, 192, 203);
    static immutable T Pink1                = T(255, 181, 197);
    static immutable T Pink2                = T(238, 169, 184);
    static immutable T Pink3                = T(205, 145, 158);
    static immutable T Pink4                = T(139,  99, 108);
    static immutable T Plum                 = T(221, 160, 221);
    static immutable T Plum1                = T(255, 187, 255);
    static immutable T Plum2                = T(238, 174, 238);
    static immutable T Plum3                = T(205, 150, 205);
    static immutable T Plum4                = T(139, 102, 139);
    static immutable T Powderblue           = T(176, 224, 230);
    static immutable T Purple               = T(160,  32, 240);
    static immutable T Purple1              = T(155,  48, 255);
    static immutable T Purple2              = T(145,  44, 238);
    static immutable T Purple3              = T(125,  38, 205);
    static immutable T Purple4              = T( 85,  26, 139);
    static immutable T Red                  = T(255,   0,   0);
    static immutable T Red1                 = T(255,   0,   0);
    static immutable T Red2                 = T(238,   0,   0);
    static immutable T Red3                 = T(205,   0,   0);
    static immutable T Red4                 = T(139,   0,   0);
    static immutable T Rosybrown            = T(188, 143, 143);
    static immutable T Rosybrown1           = T(255, 193, 193);
    static immutable T Rosybrown2           = T(238, 180, 180);
    static immutable T Rosybrown3           = T(205, 155, 155);
    static immutable T Rosybrown4           = T(139, 105, 105);
    static immutable T Royalblue            = T( 65, 105, 225);
    static immutable T Royalblue1           = T( 72, 118, 255);
    static immutable T Royalblue2           = T( 67, 110, 238);
    static immutable T Royalblue3           = T( 58,  95, 205);
    static immutable T Royalblue4           = T( 39,  64, 139);
    static immutable T Saddlebrown          = T(139,  69,  19);
    static immutable T Salmon               = T(250, 128, 114);
    static immutable T Salmon1              = T(255, 140, 105);
    static immutable T Salmon2              = T(238, 130,  98);
    static immutable T Salmon3              = T(205, 112,  84);
    static immutable T Salmon4              = T(139,  76,  57);
    static immutable T Sandybrown           = T(244, 164,  96);
    static immutable T Seagreen             = T( 46, 139,  87);
    static immutable T Seagreen1            = T( 84, 255, 159);
    static immutable T Seagreen2            = T( 78, 238, 148);
    static immutable T Seagreen3            = T( 67, 205, 128);
    static immutable T Seagreen4            = T( 46, 139,  87);
    static immutable T Seashell             = T(255, 245, 238);
    static immutable T Seashell1            = T(255, 245, 238);
    static immutable T Seashell2            = T(238, 229, 222);
    static immutable T Seashell3            = T(205, 197, 191);
    static immutable T Seashell4            = T(139, 134, 130);
    static immutable T Sienna               = T(160,  82,  45);
    static immutable T Sienna1              = T(255, 130,  71);
    static immutable T Sienna2              = T(238, 121,  66);
    static immutable T Sienna3              = T(205, 104,  57);
    static immutable T Sienna4              = T(139,  71,  38);
    static immutable T Skyblue              = T(135, 206, 235);
    static immutable T Skyblue1             = T(135, 206, 255);
    static immutable T Skyblue2             = T(126, 192, 238);
    static immutable T Skyblue3             = T(108, 166, 205);
    static immutable T Skyblue4             = T( 74, 112, 139);
    static immutable T Slateblue            = T(106,  90, 205);
    static immutable T Slateblue1           = T(131, 111, 255);
    static immutable T Slateblue2           = T(122, 103, 238);
    static immutable T Slateblue3           = T(105,  89, 205);
    static immutable T Slateblue4           = T( 71,  60, 139);
    static immutable T Slategray            = T(112, 128, 144);
    static immutable T Slategray1           = T(198, 226, 255);
    static immutable T Slategray2           = T(185, 211, 238);
    static immutable T Slategray3           = T(159, 182, 205);
    static immutable T Slategray4           = T(108, 123, 139);
    static immutable T Slategrey            = T(112, 128, 144);
    static immutable T Snow                 = T(255, 250, 250);
    static immutable T Snow1                = T(255, 250, 250);
    static immutable T Snow2                = T(238, 233, 233);
    static immutable T Snow3                = T(205, 201, 201);
    static immutable T Snow4                = T(139, 137, 137);
    static immutable T Springgreen          = T(  0, 255, 127);
    static immutable T Springgreen1         = T(  0, 255, 127);
    static immutable T Springgreen2         = T(  0, 238, 118);
    static immutable T Springgreen3         = T(  0, 205, 102);
    static immutable T Springgreen4         = T(  0, 139,  69);
    static immutable T Steelblue            = T( 70, 130, 180);
    static immutable T Steelblue1           = T( 99, 184, 255);
    static immutable T Steelblue2           = T( 92, 172, 238);
    static immutable T Steelblue3           = T( 79, 148, 205);
    static immutable T Steelblue4           = T( 54, 100, 139);
    static immutable T Tan                  = T(210, 180, 140);
    static immutable T Tan1                 = T(255, 165,  79);
    static immutable T Tan2                 = T(238, 154,  73);
    static immutable T Tan3                 = T(205, 133,  63);
    static immutable T Tan4                 = T(139,  90,  43);
    static immutable T Thistle              = T(216, 191, 216);
    static immutable T Thistle1             = T(255, 225, 255);
    static immutable T Thistle2             = T(238, 210, 238);
    static immutable T Thistle3             = T(205, 181, 205);
    static immutable T Thistle4             = T(139, 123, 139);
    static immutable T Tomato               = T(255,  99,  71);
    static immutable T Tomato1              = T(255,  99,  71);
    static immutable T Tomato2              = T(238,  92,  66);
    static immutable T Tomato3              = T(205,  79,  57);
    static immutable T Tomato4              = T(139,  54,  38);
    static immutable T Turquoise            = T( 64, 224, 208);
    static immutable T Turquoise1           = T(  0, 245, 255);
    static immutable T Turquoise2           = T(  0, 229, 238);
    static immutable T Turquoise3           = T(  0, 197, 205);
    static immutable T Turquoise4           = T(  0, 134, 139);
    static immutable T Violet               = T(238, 130, 238);
    static immutable T Violetred            = T(208,  32, 144);
    static immutable T Violetred1           = T(255,  62, 150);
    static immutable T Violetred2           = T(238,  58, 140);
    static immutable T Violetred3           = T(205,  50, 120);
    static immutable T Violetred4           = T(139,  34,  82);
    static immutable T Wheat                = T(245, 222, 179);
    static immutable T Wheat1               = T(255, 231, 186);
    static immutable T Wheat2               = T(238, 216, 174);
    static immutable T Wheat3               = T(205, 186, 150);
    static immutable T Wheat4               = T(139, 126, 102);
    static immutable T White                = T(255, 255, 255);
    static immutable T Whitesmoke           = T(245, 245, 245);
    static immutable T Yellow               = T(255, 255,   0);
    static immutable T Yellow1              = T(255, 255,   0);
    static immutable T Yellow2              = T(238, 238,   0);
    static immutable T Yellow3              = T(205, 205,   0);
    static immutable T Yellow4              = T(139, 139,   0);
    static immutable T Yellowgreen          = T(154, 205,  50);
}

@nogc
SDL_Color* _transfer(ref const Color4b src, ref SDL_Color dst) pure nothrow {
    dst.r = src.red;
    dst.g = src.green;
    dst.b = src.blue;
    dst.a = src.alpha;

    return &dst;
}

public:

/**
 * Color4b defines a structure which contains 4 ubyte values, each for red, green, blue and alpha.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Color4b {
    static immutable Colors!(Color4b) colors;
    alias colors this;

    /**
     * The color components
     */
    ubyte red, green, blue, alpha;

    /**
     * CTor
     */
    @nogc
    this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
        this.red   = red;
        this.green = green;
        this.blue  = blue;
        this.alpha = alpha;
    }

    /**
     * CTor
     */
    @nogc
     this(uint hexValue) pure nothrow {
        version (LittleEndian) {
            this.alpha = (hexValue >> 24) & 0xff;
            this.blue  = (hexValue >> 16) & 0xff;
            this.green = (hexValue >>  8) & 0xff;
            this.red   = hexValue & 0xff;
        } else {
            this.red   = (hexValue >> 24) & 0xff;
            this.green = (hexValue >> 16) & 0xff;
            this.blue  = (hexValue >>  8) & 0xff;
            this.alpha = hexValue & 0xff;
        }
    }

    /**
     * CTor
     *
     * Expect that every component is in range 0.0 .. 1.0
     */
    @nogc
    this(ref const Color4f col) pure nothrow
    in {
        assert(col.red   >= 0f && col.red   <= 1f);
        assert(col.green >= 0f && col.green <= 1f);
        assert(col.blue  >= 0f && col.blue  <= 1f);
        assert(col.alpha >= 0f && col.alpha <= 1f);
    } body {
        this.red   = cast(ubyte)(ubyte.max * col.red);
        this.green = cast(ubyte)(ubyte.max * col.green);
        this.blue  = cast(ubyte)(ubyte.max * col.blue);
        this.alpha = cast(ubyte)(ubyte.max * col.alpha);
    }

    /**
     * Returns a copy of the current Color with a given transpareny.
     */
    @nogc
    Color4b withTransparency(ubyte alpha) const pure nothrow {
        return Color4b(this.red, this.green, this.blue, alpha);
    }

    /**
     * opEquals: compares two Colors.
     */
    @nogc
    bool opEquals(ref const Color4b col) const pure nothrow {
        return this.red   == col.red &&
               this.green == col.green &&
               this.blue  == col.blue &&
               this.alpha == col.alpha;
    }

    /**
     * Returns the RGBA color information as static array
     */
    @nogc
    ubyte[4] asRGBA() const pure nothrow {
        return [this.red, this.green, this.blue, this.alpha];
    }

    /**
     * Returns RGB the color information as static array
     */
    @nogc
    ubyte[3] asRGB() const pure nothrow {
        return [this.red, this.green, this.blue];
    }

    /**
     * Returns the RGBA color information as hex value
     */
    @nogc
    uint asHex() const pure nothrow {
        version (LittleEndian)
            return ((this.alpha & 0xff) << 24) + ((this.blue & 0xff) << 16) + ((this.green & 0xff) << 8) + (this.red & 0xff);
        else
            return ((this.red & 0xff) << 24) + ((this.green & 0xff) << 16) + ((this.blue & 0xff) << 8) + (this.alpha & 0xff);
    }
}

unittest {
    const Color4b red_col = Color4b.Red;
    immutable uint hex_red = red_col.asHex();

    assert(hex_red == 0xff0000ff);
    assert(Color4b(hex_red) == red_col);
}

/**
 * Color4f defines a structure which contains 4 floats values, each for red, green, blue and alpha.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Color4f {
    static immutable Colors!(Color4f) colors;
    alias colors this;

    /**
     * The color components
     */
    float red, green, blue, alpha;

    /**
     * CTor
     */
    @nogc
    this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
        this.red   = red   > 0 ? red   / 255f : 0;
        this.green = green > 0 ? green / 255f : 0;
        this.blue  = blue  > 0 ? blue  / 255f : 0;
        this.alpha = alpha > 0 ? alpha / 255f : 0;
    }

    /**
     * CTor
     * Expect that every component is in range 0.0 .. 1.0
     */
    @nogc
    this(float red, float green, float blue, float alpha = 1) pure nothrow
    in {
        assert(red   >= 0f && red   <= 1f);
        assert(green >= 0f && green <= 1f);
        assert(blue  >= 0f && blue  <= 1f);
        assert(alpha >= 0f && alpha <= 1f);
    } body {
        this.red   = red;
        this.green = green;
        this.blue  = blue;
        this.alpha = alpha;
    }

    /**
     * CTor
     */
    @nogc
    this(ref const Color4b col) pure nothrow {
        this(col.red, col.green, col.blue, col.alpha);
    }

    /**
     * opEquals: compares two Colors.
     */
    @nogc
    bool opEquals(ref const Color4f col) const pure nothrow {
        return this.red   == col.red &&
               this.green == col.green &&
               this.blue  == col.blue &&
               this.alpha == col.alpha;
    }

    /**
     * Returns the RGBA color information as static array
     */
    @nogc
    float[4] asRGBA() const pure nothrow {
        return [this.red, this.green, this.blue, this.alpha];
    }

    /**
     * Returns RGB the color information as static array
     */
     @nogc
    float[3] asRGB() const pure nothrow {
        return [this.red, this.green, this.blue];
    }
}
