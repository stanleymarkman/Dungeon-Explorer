Shader "Custom/GA_HeatMapSolid"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MaxRadius ("MaxRadius", Range(0.0,2.0)) = 1.0 
		_Cold ("Cold", Color) = (.0, .0, .9, .0)
		_Warm ("Warm", Color) = (.9, .0, .0, .0)
		_RangeMin ("Minimum", Range(0.0, 1.0)) = 0.0
		_RangeWidth ("Width", Range(0.0, 1.0)) = 1.0
	} 
	
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		
		Pass
		{
			ZTest  LEqual
			Cull Back
			ZWrite On
			Lighting Off 
			Fog { Mode off }
			AlphaTest GEqual 0.005
			ColorMask RGBA
			
			Blend SrcAlpha OneMinusSrcAlpha     // Alpha blending
			
			Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 45 to 45
//   d3d9 - ALU: 49 to 49
//   d3d11 - ALU: 37 to 37, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 37 to 37, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Bind "color" Color
Vector 13 [_WorldSpaceCameraPos]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Float 14 [_MaxRadius]
Float 15 [_RangeMin]
Float 16 [_RangeWidth]
"!!ARBvp1.0
# 45 ALU
PARAM c[17] = { { 0, 1, 0.1, 3 },
		state.matrix.mvp,
		program.local[5..16] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
ADD R1.xyz, -R0, c[13];
DP3 R0.w, R1, R1;
RSQ R0.w, R0.w;
MUL R1.xyz, R0.w, R1;
MUL R2.xyz, -R1.zxyw, c[0].yxxw;
MAD R2.xyz, R1.yzxw, c[0].xxyw, R2;
DP3 R0.w, R2, R2;
RSQ R0.w, R0.w;
MUL R2.xyz, R0.w, R2;
MUL R3.xyz, R2.zxyw, R1.yzxw;
MAD R1.xyz, R2.yzxw, R1.zxyw, -R3;
DP3 R0.w, R1, R1;
ADD R1.w, vertex.color.x, -c[15].x;
RCP R2.w, c[16].x;
MUL R2.w, R1, R2;
RSQ R1.w, R0.w;
MIN R0.w, R2, c[0].y;
MAX R2.w, R0, c[0].x;
MUL R1.xyz, R1.w, R1;
MUL R1.xyz, vertex.texcoord[0].y, R1;
MAD R1.xyz, vertex.texcoord[0].x, R2, R1;
MUL R0.w, R2, c[14].x;
MAX R0.w, R0, c[0].z;
MUL R1.xyz, R1, R0.w;
DP4 R0.w, vertex.position, c[8];
SLT R1.w, c[0].x, R2;
SLT R2.x, R2.w, c[0].y;
MUL R2.x, R1.w, R2;
MUL R1.xyz, R1, R2.x;
MAD R0.xyz, R1, c[0].w, R0;
DP4 R1.w, R0, c[12];
DP4 R1.z, R0, c[11];
DP4 R1.x, R0, c[9];
DP4 R1.y, R0, c[10];
ADD R1, R1, -R0;
MAD R0, R1, R2.x, R0;
DP4 result.position.w, R0, c[4];
DP4 result.position.z, R0, c[3];
DP4 result.position.y, R0, c[2];
DP4 result.position.x, R0, c[1];
MOV result.texcoord[0].xy, vertex.texcoord[0];
MOV result.texcoord[1].x, R2.w;
END
# 45 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Float 13 [_MaxRadius]
Float 14 [_RangeMin]
Float 15 [_RangeWidth]
"vs_2_0
; 49 ALU
dcl_position0 v0
dcl_texcoord0 v1
dcl_color0 v2
def c16, 1.00000000, 0.00000000, 0.10000000, 3.00000000
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
add r1.xyz, -r0, c12
dp3 r0.w, r1, r1
rsq r0.w, r0.w
mul r1.xyz, r0.w, r1
mul r2.xyz, -r1.zxyw, c16.xyyw
mad r2.xyz, r1.yzxw, c16.yyxw, r2
dp3 r0.w, r2, r2
rsq r0.w, r0.w
mul r2.xyz, r0.w, r2
mul r3.xyz, r2.zxyw, r1.yzxw
mad r1.xyz, r2.yzxw, r1.zxyw, -r3
dp3 r0.w, r1, r1
rsq r2.w, r0.w
mul r1.xyz, r2.w, r1
mul r1.xyz, v1.y, r1
dp4 r2.w, v0, c7
rcp r1.w, c15.x
add r0.w, v2.x, -c14.x
mul r0.w, r0, r1
min r0.w, r0, c16.x
max r3.x, r0.w, c16.y
mad r1.xyz, v1.x, r2, r1
slt r1.w, r3.x, c16.x
slt r0.w, c16.y, r3.x
mul r0.w, r0, r1
max r0.w, -r0, r0
mul r1.w, r3.x, c13.x
max r1.w, r1, c16.z
mul r1.xyz, r1, r1.w
slt r3.y, c16, r0.w
mad r1.xyz, r1, c16.w, r0
add r1.w, -r3.y, c16.x
mul r0.xyz, r0, r1.w
mad r2.xyz, r3.y, r1, r0
dp4 r0.w, r2, c11
dp4 r0.z, r2, c10
dp4 r0.y, r2, c9
mul r1, r2, r1.w
dp4 r0.x, r2, c8
mad r0, r0, r3.y, r1
dp4 oPos.w, r0, c3
dp4 oPos.z, r0, c2
dp4 oPos.y, r0, c1
dp4 oPos.x, r0, c0
mov oT0.xy, v1
mov oT1.x, r3
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Bind "color" Color
ConstBuffer "$Globals" 80 // 60 used size, 7 vars
Float 48 [_MaxRadius]
Float 52 [_RangeMin]
Float 56 [_RangeWidth]
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 320 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Matrix 256 [_World2Object] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 41 instructions, 4 temp regs, 0 temp arrays:
// ALU 36 float, 0 int, 1 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedmldccdjmedhlgkadifbfdlidpdnhkkkiabaaaaaabiahaaaaadaaaaaa
cmaaaaaapeaaaaaageabaaaaejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapaaaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahaaaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaalaaaaaaa
abaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaaljaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaafaaaaaaapabaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfc
enebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheogiaaaaaaadaaaaaa
aiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaafmaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaafmaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaahaoaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklfdeieefckmafaaaaeaaaabaaglabaaaafjaaaaaeegiocaaaaaaaaaaa
aeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaaeegiocaaaacaaaaaa
beaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaadaaaaaafpaaaaad
bcbabaaaafaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaa
abaaaaaagfaaaaadbccabaaaacaaaaaagiaaaaacaeaaaaaadiaaaaaipcaabaaa
aaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaanaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaacaaaaaaamaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaaoaaaaaakgbkbaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaapaaaaaa
pgbpbaaaaaaaaaaaegaobaaaaaaaaaaaaaaaaaajhcaabaaaabaaaaaajgaebaia
ebaaaaaaaaaaaaaajgiecaaaabaaaaaaaeaaaaaabaaaaaahicaabaaaabaaaaaa
egacbaaaabaaaaaaegacbaaaabaaaaaaeeaaaaaficaabaaaabaaaaaadkaabaaa
abaaaaaadiaaaaahhcaabaaaabaaaaaapgapbaaaabaaaaaaegacbaaaabaaaaaa
diaaaaakhcaabaaaacaaaaaajgaebaaaabaaaaaaaceaaaaaaaaaiadpaaaaaaaa
aaaaaaaaaaaaaaaadcaaaaanhcaabaaaacaaaaaaegacbaaaabaaaaaaaceaaaaa
aaaaaaaaaaaaaaaaaaaaiadpaaaaaaaaegacbaiaebaaaaaaacaaaaaaapaaaaah
icaabaaaabaaaaaaigaabaaaacaaaaaaigaabaaaacaaaaaaeeaaaaaficaabaaa
abaaaaaadkaabaaaabaaaaaadiaaaaahhcaabaaaacaaaaaapgapbaaaabaaaaaa
egacbaaaacaaaaaadiaaaaahhcaabaaaadaaaaaaegacbaaaabaaaaaacgajbaaa
acaaaaaadcaaaaakhcaabaaaabaaaaaajgaebaaaacaaaaaajgaebaaaabaaaaaa
egacbaiaebaaaaaaadaaaaaabaaaaaahicaabaaaabaaaaaaegacbaaaabaaaaaa
egacbaaaabaaaaaaeeaaaaaficaabaaaabaaaaaadkaabaaaabaaaaaadiaaaaah
hcaabaaaabaaaaaapgapbaaaabaaaaaaegacbaaaabaaaaaadiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaafgbfbaaaadaaaaaadcaaaaajhcaabaaaabaaaaaa
agbabaaaadaaaaaaegacbaaaacaaaaaaegacbaaaabaaaaaaaaaaaaajicaabaaa
abaaaaaaakbabaaaafaaaaaabkiacaiaebaaaaaaaaaaaaaaadaaaaaaaocaaaai
icaabaaaabaaaaaadkaabaaaabaaaaaackiacaaaaaaaaaaaadaaaaaadiaaaaai
bcaabaaaacaaaaaadkaabaaaabaaaaaaakiacaaaaaaaaaaaadaaaaaadeaaaaah
bcaabaaaacaaaaaaakaabaaaacaaaaaaabeaaaaamnmmmmdndiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaaagaabaaaacaaaaaadcaaaaamhcaabaaaabaaaaaa
egacbaaaabaaaaaaaceaaaaaaaaaeaeaaaaaeaeaaaaaeaeaaaaaaaaaegacbaaa
aaaaaaaadiaaaaaipcaabaaaacaaaaaafgafbaaaabaaaaaaegiocaaaacaaaaaa
bbaaaaaadcaaaaakpcaabaaaacaaaaaaegiocaaaacaaaaaabaaaaaaaagaabaaa
abaaaaaaegaobaaaacaaaaaadcaaaaakpcaabaaaacaaaaaaegiocaaaacaaaaaa
bcaaaaaakgakbaaaabaaaaaaegaobaaaacaaaaaadcaaaaakpcaabaaaacaaaaaa
egiocaaaacaaaaaabdaaaaaapgapbaaaaaaaaaaaegaobaaaacaaaaaadbaaaaah
bcaabaaaabaaaaaaabeaaaaaaaaaaaaadkaabaaaabaaaaaadbaaaaahccaabaaa
abaaaaaadkaabaaaabaaaaaaabeaaaaaaaaaiadpdgaaaaafbccabaaaacaaaaaa
dkaabaaaabaaaaaaabaaaaahbcaabaaaabaaaaaabkaabaaaabaaaaaaakaabaaa
abaaaaaadhaaaaajpcaabaaaaaaaaaaaagaabaaaabaaaaaaegaobaaaacaaaaaa
egaobaaaaaaaaaaadiaaaaaipcaabaaaabaaaaaafgafbaaaaaaaaaaaegiocaaa
acaaaaaaabaaaaaadcaaaaakpcaabaaaabaaaaaaegiocaaaacaaaaaaaaaaaaaa
agaabaaaaaaaaaaaegaobaaaabaaaaaadcaaaaakpcaabaaaabaaaaaaegiocaaa
acaaaaaaacaaaaaakgakbaaaaaaaaaaaegaobaaaabaaaaaadcaaaaakpccabaaa
aaaaaaaaegiocaaaacaaaaaaadaaaaaapgapbaaaaaaaaaaaegaobaaaabaaaaaa
dgaaaaafdccabaaaabaaaaaaegbabaaaadaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec3 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp float _RangeWidth;
uniform highp float _RangeMin;
uniform highp float _MaxRadius;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  highp vec3 tmpvar_2;
  highp float size_3;
  highp vec4 tmpvar_4;
  tmpvar_4 = (_Object2World * _glesVertex);
  tmpvar_1 = tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_5 = normalize((_WorldSpaceCameraPos - tmpvar_4.xyz));
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize(((tmpvar_5.yzx * vec3(0.0, 0.0, 1.0)) - (tmpvar_5.zxy * vec3(1.0, 0.0, 0.0))));
  lowp float tmpvar_7;
  tmpvar_7 = _glesColor.x;
  size_3 = tmpvar_7;
  highp float tmpvar_8;
  tmpvar_8 = max (min (((size_3 - _RangeMin) / _RangeWidth), 1.0), 0.0);
  size_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = normalize(((tmpvar_6.yzx * tmpvar_5.zxy) - (tmpvar_6.zxy * tmpvar_5.yzx)));
  if (((tmpvar_8 > 0.0) && (tmpvar_8 < 1.0))) {
    tmpvar_1.xyz = (tmpvar_4.xyz + ((((_glesMultiTexCoord0.x * tmpvar_6) + (_glesMultiTexCoord0.y * tmpvar_9)) * max ((tmpvar_8 * _MaxRadius), 0.1)) * 3.0));
    tmpvar_1 = (_World2Object * tmpvar_1);
  };
  tmpvar_2.x = tmpvar_8;
  gl_Position = (glstate_matrix_mvp * tmpvar_1);
  xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
  xlv_TEXCOORD1 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
highp vec4 xlat_mutable_Warm;
highp vec4 xlat_mutable_Cold;
uniform highp vec4 _Warm;
uniform highp vec4 _Cold;
void main ()
{
  xlat_mutable_Cold = _Cold;
  xlat_mutable_Warm = _Warm;
  highp vec4 tmpvar_1;
  mediump float radius_2;
  mediump vec4 col_3;
  col_3 = vec4(0.0, 0.0, 0.0, 0.0);
  highp float tmpvar_4;
  tmpvar_4 = (sqrt(dot (xlv_TEXCOORD0, xlv_TEXCOORD0)) * 2.0);
  radius_2 = tmpvar_4;
  if ((radius_2 <= 1.0)) {
    mediump vec3 n_5;
    xlat_mutable_Cold.w = 1.0;
    xlat_mutable_Warm.w = 1.0;
    highp vec4 tmpvar_6;
    tmpvar_6 = ((xlv_TEXCOORD1.x * xlat_mutable_Warm) + ((1.0 - xlv_TEXCOORD1.x) * xlat_mutable_Cold));
    col_3 = tmpvar_6;
    n_5.xy = xlv_TEXCOORD0;
    n_5.z = sqrt((((n_5.x * n_5.x) + (n_5.y * n_5.y)) - 0.5));
    mediump vec3 tmpvar_7;
    tmpvar_7 = normalize(n_5);
    n_5 = tmpvar_7;
    col_3.xyz = (col_3 * ((0.7 * dot (normalize(tmpvar_7), normalize(vec3(1.5, 1.5, 0.5)))) + 0.3)).xyz;
    col_3.w = 1.0;
  };
  tmpvar_1 = col_3;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec3 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp float _RangeWidth;
uniform highp float _RangeMin;
uniform highp float _MaxRadius;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesColor;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 tmpvar_1;
  highp vec3 tmpvar_2;
  highp float size_3;
  highp vec4 tmpvar_4;
  tmpvar_4 = (_Object2World * _glesVertex);
  tmpvar_1 = tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_5 = normalize((_WorldSpaceCameraPos - tmpvar_4.xyz));
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize(((tmpvar_5.yzx * vec3(0.0, 0.0, 1.0)) - (tmpvar_5.zxy * vec3(1.0, 0.0, 0.0))));
  lowp float tmpvar_7;
  tmpvar_7 = _glesColor.x;
  size_3 = tmpvar_7;
  highp float tmpvar_8;
  tmpvar_8 = max (min (((size_3 - _RangeMin) / _RangeWidth), 1.0), 0.0);
  size_3 = tmpvar_8;
  highp vec3 tmpvar_9;
  tmpvar_9 = normalize(((tmpvar_6.yzx * tmpvar_5.zxy) - (tmpvar_6.zxy * tmpvar_5.yzx)));
  if (((tmpvar_8 > 0.0) && (tmpvar_8 < 1.0))) {
    tmpvar_1.xyz = (tmpvar_4.xyz + ((((_glesMultiTexCoord0.x * tmpvar_6) + (_glesMultiTexCoord0.y * tmpvar_9)) * max ((tmpvar_8 * _MaxRadius), 0.1)) * 3.0));
    tmpvar_1 = (_World2Object * tmpvar_1);
  };
  tmpvar_2.x = tmpvar_8;
  gl_Position = (glstate_matrix_mvp * tmpvar_1);
  xlv_TEXCOORD0 = _glesMultiTexCoord0.xy;
  xlv_TEXCOORD1 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD1;
varying highp vec2 xlv_TEXCOORD0;
highp vec4 xlat_mutable_Warm;
highp vec4 xlat_mutable_Cold;
uniform highp vec4 _Warm;
uniform highp vec4 _Cold;
void main ()
{
  xlat_mutable_Cold = _Cold;
  xlat_mutable_Warm = _Warm;
  highp vec4 tmpvar_1;
  mediump float radius_2;
  mediump vec4 col_3;
  col_3 = vec4(0.0, 0.0, 0.0, 0.0);
  highp float tmpvar_4;
  tmpvar_4 = (sqrt(dot (xlv_TEXCOORD0, xlv_TEXCOORD0)) * 2.0);
  radius_2 = tmpvar_4;
  if ((radius_2 <= 1.0)) {
    mediump vec3 n_5;
    xlat_mutable_Cold.w = 1.0;
    xlat_mutable_Warm.w = 1.0;
    highp vec4 tmpvar_6;
    tmpvar_6 = ((xlv_TEXCOORD1.x * xlat_mutable_Warm) + ((1.0 - xlv_TEXCOORD1.x) * xlat_mutable_Cold));
    col_3 = tmpvar_6;
    n_5.xy = xlv_TEXCOORD0;
    n_5.z = sqrt((((n_5.x * n_5.x) + (n_5.y * n_5.y)) - 0.5));
    mediump vec3 tmpvar_7;
    tmpvar_7 = normalize(n_5);
    n_5 = tmpvar_7;
    col_3.xyz = (col_3 * ((0.7 * dot (normalize(tmpvar_7), normalize(vec3(1.5, 1.5, 0.5)))) + 0.3)).xyz;
    col_3.w = 1.0;
  };
  tmpvar_1 = col_3;
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Bind "color" Color
Matrix 0 [glstate_matrix_mvp]
Vector 12 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Float 13 [_MaxRadius]
Float 14 [_RangeMin]
Float 15 [_RangeWidth]
"agal_vs
c16 1.0 0.0 0.1 3.0
[bc]
bdaaaaaaaaaaaeacaaaaaaoeaaaaaaaaagaaaaoeabaaaaaa dp4 r0.z, a0, c6
bdaaaaaaaaaaabacaaaaaaoeaaaaaaaaaeaaaaoeabaaaaaa dp4 r0.x, a0, c4
bdaaaaaaaaaaacacaaaaaaoeaaaaaaaaafaaaaoeabaaaaaa dp4 r0.y, a0, c5
bfaaaaaaabaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r1.xyz, r0.xyzz
abaaaaaaabaaahacabaaaakeacaaaaaaamaaaaoeabaaaaaa add r1.xyz, r1.xyzz, c12
bcaaaaaaaaaaaiacabaaaakeacaaaaaaabaaaakeacaaaaaa dp3 r0.w, r1.xyzz, r1.xyzz
akaaaaaaaaaaaiacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa rsq r0.w, r0.w
adaaaaaaabaaahacaaaaaappacaaaaaaabaaaakeacaaaaaa mul r1.xyz, r0.w, r1.xyzz
bfaaaaaaacaaahacabaaaafcacaaaaaaaaaaaaaaaaaaaaaa neg r2.xyz, r1.zxyy
adaaaaaaacaaahacacaaaafcacaaaaaabaaaaaneabaaaaaa mul r2.xyz, r2.zxyy, c16.xyyw
adaaaaaaadaaahacabaaaaajacaaaaaabaaaaamfabaaaaaa mul r3.xyz, r1.yzxx, c16.yyxw
abaaaaaaacaaahacadaaaakeacaaaaaaacaaaakeacaaaaaa add r2.xyz, r3.xyzz, r2.xyzz
bcaaaaaaaaaaaiacacaaaakeacaaaaaaacaaaakeacaaaaaa dp3 r0.w, r2.xyzz, r2.xyzz
akaaaaaaaaaaaiacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa rsq r0.w, r0.w
adaaaaaaacaaahacaaaaaappacaaaaaaacaaaakeacaaaaaa mul r2.xyz, r0.w, r2.xyzz
adaaaaaaadaaahacacaaaafcacaaaaaaabaaaaajacaaaaaa mul r3.xyz, r2.zxyy, r1.yzxx
adaaaaaaaeaaahacacaaaaajacaaaaaaabaaaafcacaaaaaa mul r4.xyz, r2.yzxx, r1.zxyy
acaaaaaaabaaahacaeaaaakeacaaaaaaadaaaakeacaaaaaa sub r1.xyz, r4.xyzz, r3.xyzz
bcaaaaaaaaaaaiacabaaaakeacaaaaaaabaaaakeacaaaaaa dp3 r0.w, r1.xyzz, r1.xyzz
akaaaaaaacaaaiacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa rsq r2.w, r0.w
adaaaaaaabaaahacacaaaappacaaaaaaabaaaakeacaaaaaa mul r1.xyz, r2.w, r1.xyzz
adaaaaaaabaaahacadaaaaffaaaaaaaaabaaaakeacaaaaaa mul r1.xyz, a3.y, r1.xyzz
bdaaaaaaacaaaiacaaaaaaoeaaaaaaaaahaaaaoeabaaaaaa dp4 r2.w, a0, c7
aaaaaaaaadaaaiacapaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r3.w, c15
afaaaaaaabaaaiacadaaaappacaaaaaaaaaaaaaaaaaaaaaa rcp r1.w, r3.w
acaaaaaaaaaaaiacacaaaaaaaaaaaaaaaoaaaaaaabaaaaaa sub r0.w, a2.x, c14.x
adaaaaaaaaaaaiacaaaaaappacaaaaaaabaaaappacaaaaaa mul r0.w, r0.w, r1.w
agaaaaaaaaaaaiacaaaaaappacaaaaaabaaaaaaaabaaaaaa min r0.w, r0.w, c16.x
ahaaaaaaadaaabacaaaaaappacaaaaaabaaaaaffabaaaaaa max r3.x, r0.w, c16.y
adaaaaaaaeaaahacadaaaaaaaaaaaaaaacaaaakeacaaaaaa mul r4.xyz, a3.x, r2.xyzz
abaaaaaaabaaahacaeaaaakeacaaaaaaabaaaakeacaaaaaa add r1.xyz, r4.xyzz, r1.xyzz
ckaaaaaaabaaaiacadaaaaaaacaaaaaabaaaaaaaabaaaaaa slt r1.w, r3.x, c16.x
ckaaaaaaaaaaaiacbaaaaaffabaaaaaaadaaaaaaacaaaaaa slt r0.w, c16.y, r3.x
adaaaaaaaaaaaiacaaaaaappacaaaaaaabaaaappacaaaaaa mul r0.w, r0.w, r1.w
bfaaaaaaaeaaaiacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa neg r4.w, r0.w
ahaaaaaaaaaaaiacaeaaaappacaaaaaaaaaaaappacaaaaaa max r0.w, r4.w, r0.w
adaaaaaaabaaaiacadaaaaaaacaaaaaaanaaaaaaabaaaaaa mul r1.w, r3.x, c13.x
ahaaaaaaabaaaiacabaaaappacaaaaaabaaaaakkabaaaaaa max r1.w, r1.w, c16.z
adaaaaaaabaaahacabaaaakeacaaaaaaabaaaappacaaaaaa mul r1.xyz, r1.xyzz, r1.w
ckaaaaaaadaaacacbaaaaaoeabaaaaaaaaaaaappacaaaaaa slt r3.y, c16, r0.w
adaaaaaaabaaahacabaaaakeacaaaaaabaaaaappabaaaaaa mul r1.xyz, r1.xyzz, c16.w
abaaaaaaabaaahacabaaaakeacaaaaaaaaaaaakeacaaaaaa add r1.xyz, r1.xyzz, r0.xyzz
bfaaaaaaaeaaacacadaaaaffacaaaaaaaaaaaaaaaaaaaaaa neg r4.y, r3.y
abaaaaaaabaaaiacaeaaaaffacaaaaaabaaaaaaaabaaaaaa add r1.w, r4.y, c16.x
adaaaaaaaaaaahacaaaaaakeacaaaaaaabaaaappacaaaaaa mul r0.xyz, r0.xyzz, r1.w
adaaaaaaacaaahacadaaaaffacaaaaaaabaaaakeacaaaaaa mul r2.xyz, r3.y, r1.xyzz
abaaaaaaacaaahacacaaaakeacaaaaaaaaaaaakeacaaaaaa add r2.xyz, r2.xyzz, r0.xyzz
bdaaaaaaaaaaaiacacaaaaoeacaaaaaaalaaaaoeabaaaaaa dp4 r0.w, r2, c11
bdaaaaaaaaaaaeacacaaaaoeacaaaaaaakaaaaoeabaaaaaa dp4 r0.z, r2, c10
bdaaaaaaaaaaacacacaaaaoeacaaaaaaajaaaaoeabaaaaaa dp4 r0.y, r2, c9
adaaaaaaabaaapacacaaaaoeacaaaaaaabaaaappacaaaaaa mul r1, r2, r1.w
bdaaaaaaaaaaabacacaaaaoeacaaaaaaaiaaaaoeabaaaaaa dp4 r0.x, r2, c8
adaaaaaaaaaaapacaaaaaaoeacaaaaaaadaaaaffacaaaaaa mul r0, r0, r3.y
abaaaaaaaaaaapacaaaaaaoeacaaaaaaabaaaaoeacaaaaaa add r0, r0, r1
bdaaaaaaaaaaaiadaaaaaaoeacaaaaaaadaaaaoeabaaaaaa dp4 o0.w, r0, c3
bdaaaaaaaaaaaeadaaaaaaoeacaaaaaaacaaaaoeabaaaaaa dp4 o0.z, r0, c2
bdaaaaaaaaaaacadaaaaaaoeacaaaaaaabaaaaoeabaaaaaa dp4 o0.y, r0, c1
bdaaaaaaaaaaabadaaaaaaoeacaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, r0, c0
aaaaaaaaaaaaadaeadaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov v0.xy, a3
aaaaaaaaabaaabaeadaaaaaaacaaaaaaaaaaaaaaaaaaaaaa mov v1.x, r3.x
aaaaaaaaaaaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c0
aaaaaaaaabaaaoaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v1.yzw, c0
"
}

SubProgram "d3d11_9x " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Bind "color" Color
ConstBuffer "$Globals" 80 // 60 used size, 7 vars
Float 48 [_MaxRadius]
Float 52 [_RangeMin]
Float 56 [_RangeWidth]
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 320 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Matrix 256 [_World2Object] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 41 instructions, 4 temp regs, 0 temp arrays:
// ALU 36 float, 0 int, 1 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_1
eefiecedbhnlemngcholikpkfgphpmbmndcgniinabaaaaaahaakaaaaaeaaaaaa
daaaaaaaieadaaaadiajaaaaaaakaaaaebgpgodjemadaaaaemadaaaaaaacpopp
peacaaaafiaaaaaaaeaaceaaaaaafeaaaaaafeaaaaaaceaaabaafeaaaaaaadaa
abaaabaaaaaaaaaaabaaaeaaabaaacaaaaaaaaaaacaaaaaaaeaaadaaaaaaaaaa
acaaamaaaiaaahaaaaaaaaaaaaaaaaaaaaacpoppfbaaaaafapaaapkaaaaaiadp
aaaaaaaamnmmmmdnaaaaeaeabpaaaaacafaaaaiaaaaaapjabpaaaaacafaaadia
adaaapjabpaaaaacafaaafiaafaaapjaafaaaaadaaaaapiaaaaaffjaaiaaoeka
aeaaaaaeaaaaapiaahaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaajaaoeka
aaaakkjaaaaaoeiaaeaaaaaeaaaaapiaakaaoekaaaaappjaaaaaoeiaacaaaaad
abaaahiaaaaamjibacaamjkaaiaaaaadabaaaiiaabaaoeiaabaaoeiaahaaaaac
abaaaiiaabaappiaafaaaaadabaaahiaabaappiaabaaoeiaafaaaaadacaaahia
abaamjiaapaanekaaeaaaaaeacaaahiaabaaoeiaapaamfkaacaaoeibceaaaaac
adaaahiaacaaoeiaafaaaaadacaaahiaabaaoeiaadaanciaaeaaaaaeabaaahia
adaamjiaabaamjiaacaaoeibceaaaaacacaaahiaabaaoeiaafaaaaadabaaahia
acaaoeiaadaaffjaaeaaaaaeabaaahiaadaaaajaadaaoeiaabaaoeiaacaaaaad
abaaaiiaafaaaajaabaaffkbagaaaaacacaaabiaabaakkkaafaaaaadabaaaiia
abaappiaacaaaaiaakaaaaadabaaaiiaabaappiaapaaaakaalaaaaadabaaaiia
abaappiaapaaffkaafaaaaadacaaabiaabaappiaabaaaakaalaaaaadacaaabia
acaaaaiaapaakkkaafaaaaadabaaahiaabaaoeiaacaaaaiaaeaaaaaeabaaahia
abaaoeiaapaappkaaaaaoeiaafaaaaadacaaapiaabaaffiaamaaoekaaeaaaaae
acaaapiaalaaoekaabaaaaiaacaaoeiaaeaaaaaeacaaapiaanaaoekaabaakkia
acaaoeiaaeaaaaaeacaaapiaaoaaoekaaaaappiaacaaoeiaamaaaaadabaaabia
apaaffkaabaappiaamaaaaadabaaaciaabaappiaapaaaakaabaaaaacabaaaboa
abaappiaafaaaaadabaaabiaabaaffiaabaaaaiabcaaaaaeadaaapiaabaaaaia
acaaoeiaaaaaoeiaafaaaaadaaaaapiaadaaffiaaeaaoekaaeaaaaaeaaaaapia
adaaoekaadaaaaiaaaaaoeiaaeaaaaaeaaaaapiaafaaoekaadaakkiaaaaaoeia
aeaaaaaeaaaaapiaagaaoekaadaappiaaaaaoeiaaeaaaaaeaaaaadmaaaaappia
aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiaabaaaaacaaaaadoaadaaoeja
ppppaaaafdeieefckmafaaaaeaaaabaaglabaaaafjaaaaaeegiocaaaaaaaaaaa
aeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaaeegiocaaaacaaaaaa
beaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaadaaaaaafpaaaaad
bcbabaaaafaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaa
abaaaaaagfaaaaadbccabaaaacaaaaaagiaaaaacaeaaaaaadiaaaaaipcaabaaa
aaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaanaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaacaaaaaaamaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaaoaaaaaakgbkbaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaapaaaaaa
pgbpbaaaaaaaaaaaegaobaaaaaaaaaaaaaaaaaajhcaabaaaabaaaaaajgaebaia
ebaaaaaaaaaaaaaajgiecaaaabaaaaaaaeaaaaaabaaaaaahicaabaaaabaaaaaa
egacbaaaabaaaaaaegacbaaaabaaaaaaeeaaaaaficaabaaaabaaaaaadkaabaaa
abaaaaaadiaaaaahhcaabaaaabaaaaaapgapbaaaabaaaaaaegacbaaaabaaaaaa
diaaaaakhcaabaaaacaaaaaajgaebaaaabaaaaaaaceaaaaaaaaaiadpaaaaaaaa
aaaaaaaaaaaaaaaadcaaaaanhcaabaaaacaaaaaaegacbaaaabaaaaaaaceaaaaa
aaaaaaaaaaaaaaaaaaaaiadpaaaaaaaaegacbaiaebaaaaaaacaaaaaaapaaaaah
icaabaaaabaaaaaaigaabaaaacaaaaaaigaabaaaacaaaaaaeeaaaaaficaabaaa
abaaaaaadkaabaaaabaaaaaadiaaaaahhcaabaaaacaaaaaapgapbaaaabaaaaaa
egacbaaaacaaaaaadiaaaaahhcaabaaaadaaaaaaegacbaaaabaaaaaacgajbaaa
acaaaaaadcaaaaakhcaabaaaabaaaaaajgaebaaaacaaaaaajgaebaaaabaaaaaa
egacbaiaebaaaaaaadaaaaaabaaaaaahicaabaaaabaaaaaaegacbaaaabaaaaaa
egacbaaaabaaaaaaeeaaaaaficaabaaaabaaaaaadkaabaaaabaaaaaadiaaaaah
hcaabaaaabaaaaaapgapbaaaabaaaaaaegacbaaaabaaaaaadiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaafgbfbaaaadaaaaaadcaaaaajhcaabaaaabaaaaaa
agbabaaaadaaaaaaegacbaaaacaaaaaaegacbaaaabaaaaaaaaaaaaajicaabaaa
abaaaaaaakbabaaaafaaaaaabkiacaiaebaaaaaaaaaaaaaaadaaaaaaaocaaaai
icaabaaaabaaaaaadkaabaaaabaaaaaackiacaaaaaaaaaaaadaaaaaadiaaaaai
bcaabaaaacaaaaaadkaabaaaabaaaaaaakiacaaaaaaaaaaaadaaaaaadeaaaaah
bcaabaaaacaaaaaaakaabaaaacaaaaaaabeaaaaamnmmmmdndiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaaagaabaaaacaaaaaadcaaaaamhcaabaaaabaaaaaa
egacbaaaabaaaaaaaceaaaaaaaaaeaeaaaaaeaeaaaaaeaeaaaaaaaaaegacbaaa
aaaaaaaadiaaaaaipcaabaaaacaaaaaafgafbaaaabaaaaaaegiocaaaacaaaaaa
bbaaaaaadcaaaaakpcaabaaaacaaaaaaegiocaaaacaaaaaabaaaaaaaagaabaaa
abaaaaaaegaobaaaacaaaaaadcaaaaakpcaabaaaacaaaaaaegiocaaaacaaaaaa
bcaaaaaakgakbaaaabaaaaaaegaobaaaacaaaaaadcaaaaakpcaabaaaacaaaaaa
egiocaaaacaaaaaabdaaaaaapgapbaaaaaaaaaaaegaobaaaacaaaaaadbaaaaah
bcaabaaaabaaaaaaabeaaaaaaaaaaaaadkaabaaaabaaaaaadbaaaaahccaabaaa
abaaaaaadkaabaaaabaaaaaaabeaaaaaaaaaiadpdgaaaaafbccabaaaacaaaaaa
dkaabaaaabaaaaaaabaaaaahbcaabaaaabaaaaaabkaabaaaabaaaaaaakaabaaa
abaaaaaadhaaaaajpcaabaaaaaaaaaaaagaabaaaabaaaaaaegaobaaaacaaaaaa
egaobaaaaaaaaaaadiaaaaaipcaabaaaabaaaaaafgafbaaaaaaaaaaaegiocaaa
acaaaaaaabaaaaaadcaaaaakpcaabaaaabaaaaaaegiocaaaacaaaaaaaaaaaaaa
agaabaaaaaaaaaaaegaobaaaabaaaaaadcaaaaakpcaabaaaabaaaaaaegiocaaa
acaaaaaaacaaaaaakgakbaaaaaaaaaaaegaobaaaabaaaaaadcaaaaakpccabaaa
aaaaaaaaegiocaaaacaaaaaaadaaaaaapgapbaaaaaaaaaaaegaobaaaabaaaaaa
dgaaaaafdccabaaaabaaaaaaegbabaaaadaaaaaadoaaaaabejfdeheomaaaaaaa
agaaaaaaaiaaaaaajiaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaa
kbaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaakjaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaacaaaaaaahaaaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
adaaaaaaapadaaaalaaaaaaaabaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaa
ljaaaaaaaaaaaaaaaaaaaaaaadaaaaaaafaaaaaaapabaaaafaepfdejfeejepeo
aafeebeoehefeofeaaeoepfcenebemaafeeffiedepepfceeaaedepemepfcaakl
epfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaa
fmaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaahaoaaaafdfgfpfaepfdejfe
ejepeoaafeeffiedepepfceeaaklklkl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 321
struct v2f {
    highp vec4 pos;
    highp vec2 uv_MainTex;
    highp vec3 normal;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 315
uniform highp vec4 _Cold;
uniform highp vec4 _Warm;
uniform highp float _MaxRadius;
uniform highp float _RangeMin;
#line 319
uniform highp float _RangeWidth;
uniform highp vec4 _MainTex_ST;
#line 328
uniform sampler2D _MainTex;
#line 328
v2f vert( in appdata_full v ) {
    v.vertex = (_Object2World * v.vertex);
    v.normal = normalize((_WorldSpaceCameraPos - vec3( v.vertex)));
    #line 332
    highp vec3 up = vec3( 0.0, 1.0, 0.0);
    highp vec3 side = normalize(cross( v.normal, up));
    highp float size = v.color.x;
    size -= _RangeMin;
    #line 336
    size /= _RangeWidth;
    size = min( size, 1.0);
    size = max( size, 0.0);
    up = normalize(cross( side, v.normal));
    #line 340
    if (((size > 0.0) && (size < 1.0))){
        v.vertex.xyz = (v.vertex.xyz + ((((v.texcoord.x * side) + (v.texcoord.y * up)) * max( (size * _MaxRadius), 0.1)) * 3.0));
        v.vertex = (_World2Object * v.vertex);
    }
    #line 345
    v2f o;
    o.pos = (glstate_matrix_mvp * v.vertex);
    o.uv_MainTex = vec2( v.texcoord);
    o.normal.x = size;
    #line 349
    return o;
}

out highp vec2 xlv_TEXCOORD0;
out highp vec3 xlv_TEXCOORD1;
void main() {
    v2f xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec2(xl_retval.uv_MainTex);
    xlv_TEXCOORD1 = vec3(xl_retval.normal);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 321
struct v2f {
    highp vec4 pos;
    highp vec2 uv_MainTex;
    highp vec3 normal;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 315
uniform highp vec4 _Cold;
uniform highp vec4 _Warm;
uniform highp float _MaxRadius;
uniform highp float _RangeMin;
#line 319
uniform highp float _RangeWidth;
uniform highp vec4 _MainTex_ST;
#line 328
uniform sampler2D _MainTex;
highp vec4 xlat_mutable_Cold;
highp vec4 xlat_mutable_Warm;
#line 352
highp vec4 frag( in v2f IN ) {
    #line 354
    mediump vec4 col = vec4( 0.0, 0.0, 0.0, 0.0);
    mediump float radius = (length(IN.uv_MainTex.xy) * 2.0);
    if ((radius <= 1.0)){
        #line 358
        xlat_mutable_Warm.w = xlat_mutable_Cold.w = 1.0;
        col = ((IN.normal.x * xlat_mutable_Warm) + ((1.0 - IN.normal.x) * xlat_mutable_Cold));
        mediump vec3 n;
        n.xy = IN.uv_MainTex.xy;
        #line 362
        n.z = sqrt((((n.x * n.x) + (n.y * n.y)) - 0.5));
        n = normalize(n);
        mediump float a = 0.3;
        col *= (((1.0 - a) * dot( normalize(n), normalize(vec3( 1.5, 1.5, 0.5)))) + a);
        #line 366
        col.w = 1.0;
    }
    return col;
}
in highp vec2 xlv_TEXCOORD0;
in highp vec3 xlv_TEXCOORD1;
void main() {
    xlat_mutable_Cold = _Cold;
    xlat_mutable_Warm = _Warm;
    highp vec4 xl_retval;
    v2f xlt_IN;
    xlt_IN.pos = vec4(0.0);
    xlt_IN.uv_MainTex = vec2(xlv_TEXCOORD0);
    xlt_IN.normal = vec3(xlv_TEXCOORD1);
    xl_retval = frag( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 32 to 32, TEX: 0 to 0
//   d3d9 - ALU: 34 to 34
//   d3d11 - ALU: 15 to 15, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 15 to 15, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 0 [_Cold]
Vector 1 [_Warm]
"!!ARBfp1.0
# 32 ALU, 0 TEX
PARAM c[4] = { program.local[0..1],
		{ 0.48206806, 0.16060388, 0, 2 },
		{ 1, 0.5, 0.30004883 } };
TEMP R0;
TEMP R1;
TEMP R2;
MUL R0.x, fragment.texcoord[0].y, fragment.texcoord[0].y;
MAD R0.x, fragment.texcoord[0], fragment.texcoord[0], R0;
ADD R0.x, R0, -c[3].y;
RSQ R0.x, R0.x;
RCP R2.z, R0.x;
MOV R2.xy, fragment.texcoord[0];
DP3 R2.w, R2, R2;
MOV R0.xyz, c[0];
MOV R0.w, c[3].x;
ADD R1.x, -fragment.texcoord[1], c[3];
MUL R1, R1.x, R0;
RSQ R2.w, R2.w;
MOV R0.xyz, c[1];
MOV R0.w, c[3].x;
MAD R0, fragment.texcoord[1].x, R0, R1;
MUL R1.xyz, R2.w, R2;
MUL R2.xy, fragment.texcoord[0], fragment.texcoord[0];
ADD R1.w, R2.x, R2.y;
DP3 R2.z, R1, R1;
RSQ R2.x, R2.z;
MUL R1.xyz, R2.x, R1;
DP3 R1.y, R1, c[2].xxyw;
RSQ R1.w, R1.w;
RCP R1.w, R1.w;
MUL R1.x, R1.w, c[2].w;
ADD R2.x, R1, -c[3];
CMP R0, -R2.x, c[2].z, R0;
ADD R1.y, R1, c[3].z;
MUL R1, R0, R1.y;
CMP R0, -R2.x, R0, R1;
CMP result.color.w, -R2.x, R0, c[3].x;
MOV result.color.xyz, R0;
END
# 32 instructions, 3 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_Cold]
Vector 1 [_Warm]
"ps_2_0
; 34 ALU
def c2, 1.00000000, 2.00000000, -1.00000000, 0.00000000
def c3, -0.50000000, 0.48206806, 0.16060388, 0.30004883
dcl t0.xy
dcl t1.x
mul_pp r0.x, t0.y, t0.y
mad_pp r0.x, t0, t0, r0
add_pp r0.x, r0, c3
rsq_pp r0.x, r0.x
mov_pp r1.xy, t0
rcp_pp r1.z, r0.x
dp3_pp r0.x, r1, r1
rsq_pp r0.x, r0.x
mul_pp r0.xyz, r0.x, r1
mul r1.xy, t0, t0
add r1.x, r1, r1.y
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, c2.y
add_pp r1.x, r1, c2.z
mov r3.xyz, c0
mov r3.w, c2.x
add r2.x, -t1, c2
mul r2, r2.x, r3
mov r3.xyz, c1
mov r3.w, c2.x
mad r2, t1.x, r3, r2
dp3_pp r3.x, r0, r0
rsq_pp r3.x, r3.x
mul_pp r0.xyz, r3.x, r0
cmp_pp r2, -r1.x, r2, c2.w
mov r3.z, c3
mov r3.xy, c3.y
dp3_pp r0.x, r0, r3
add_pp r0.x, r0, c3.w
mul_pp r0, r2, r0.x
cmp_pp r0, -r1.x, r0, r2
cmp_pp r0.w, -r1.x, c2.x, r0
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 80 // 48 used size, 7 vars
Vector 16 [_Cold] 4
Vector 32 [_Warm] 4
BindCB "$Globals" 0
// 18 instructions, 2 temp regs, 0 temp arrays:
// ALU 14 float, 0 int, 1 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedmjnhephknoogopnjamoaapfdojlhlmkfabaaaaaapmacaaaaadaaaaaa
cmaaaaaajmaaaaaanaaaaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafmaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahabaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklklepfdeheo
cmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaa
apaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcceacaaaaeaaaaaaaijaaaaaa
fjaaaaaeegiocaaaaaaaaaaaadaaaaaagcbaaaaddcbabaaaabaaaaaagcbaaaad
bcbabaaaacaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaapaaaaah
bcaabaaaaaaaaaaaegbabaaaabaaaaaaegbabaaaabaaaaaaaaaaaaahccaabaaa
aaaaaaaaakaabaaaaaaaaaaaabeaaaaaaaaaaalpelaaaaafbcaabaaaaaaaaaaa
akaabaaaaaaaaaaabnaaaaahbcaabaaaaaaaaaaaabeaaaaaaaaaaadpakaabaaa
aaaaaaaaelaaaaafecaabaaaabaaaaaabkaabaaaaaaaaaaadgaaaaafdcaabaaa
abaaaaaaegbabaaaabaaaaaabaaaaaahccaabaaaaaaaaaaaegacbaaaabaaaaaa
egacbaaaabaaaaaaeeaaaaafccaabaaaaaaaaaaabkaabaaaaaaaaaaadiaaaaah
ocaabaaaaaaaaaaafgafbaaaaaaaaaaaagajbaaaabaaaaaabaaaaaakccaabaaa
aaaaaaaajgahbaaaaaaaaaaaaceaaaaapidadadppidadadppfolgkdoaaaaaaaa
dcaaaaajccaabaaaaaaaaaaabkaabaaaaaaaaaaaabeaaaaadddddddpabeaaaaa
jkjjjjdoaaaaaaaiecaabaaaaaaaaaaaakbabaiaebaaaaaaacaaaaaaabeaaaaa
aaaaiadpdiaaaaaihcaabaaaabaaaaaakgakbaaaaaaaaaaaegiccaaaaaaaaaaa
abaaaaaadcaaaaakhcaabaaaabaaaaaaagbabaaaacaaaaaaegiccaaaaaaaaaaa
acaaaaaaegacbaaaabaaaaaadiaaaaahhcaabaaaabaaaaaafgafbaaaaaaaaaaa
egacbaaaabaaaaaadgaaaaaficaabaaaabaaaaaaabeaaaaaaaaaiadpabaaaaah
pccabaaaaaaaaaaaagaabaaaaaaaaaaaegaobaaaabaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

SubProgram "flash " {
Keywords { }
Vector 0 [_Cold]
Vector 1 [_Warm]
"agal_ps
c2 1.0 2.0 -1.0 0.0
c3 -0.5 0.482068 0.160604 0.300049
[bc]
adaaaaaaaaaaabacaaaaaaffaeaaaaaaaaaaaaffaeaaaaaa mul r0.x, v0.y, v0.y
adaaaaaaabaaabacaaaaaaoeaeaaaaaaaaaaaaoeaeaaaaaa mul r1.x, v0, v0
abaaaaaaaaaaabacabaaaaaaacaaaaaaaaaaaaaaacaaaaaa add r0.x, r1.x, r0.x
abaaaaaaaaaaabacaaaaaaaaacaaaaaaadaaaaoeabaaaaaa add r0.x, r0.x, c3
akaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rsq r0.x, r0.x
aaaaaaaaabaaadacaaaaaaoeaeaaaaaaaaaaaaaaaaaaaaaa mov r1.xy, v0
afaaaaaaabaaaeacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rcp r1.z, r0.x
bcaaaaaaaaaaabacabaaaakeacaaaaaaabaaaakeacaaaaaa dp3 r0.x, r1.xyzz, r1.xyzz
akaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rsq r0.x, r0.x
adaaaaaaaaaaahacaaaaaaaaacaaaaaaabaaaakeacaaaaaa mul r0.xyz, r0.x, r1.xyzz
adaaaaaaabaaadacaaaaaaoeaeaaaaaaaaaaaaoeaeaaaaaa mul r1.xy, v0, v0
abaaaaaaabaaabacabaaaaaaacaaaaaaabaaaaffacaaaaaa add r1.x, r1.x, r1.y
akaaaaaaabaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rsq r1.x, r1.x
afaaaaaaabaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rcp r1.x, r1.x
adaaaaaaabaaabacabaaaaaaacaaaaaaacaaaaffabaaaaaa mul r1.x, r1.x, c2.y
abaaaaaaabaaabacabaaaaaaacaaaaaaacaaaakkabaaaaaa add r1.x, r1.x, c2.z
aaaaaaaaadaaahacaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r3.xyz, c0
aaaaaaaaadaaaiacacaaaaaaabaaaaaaaaaaaaaaaaaaaaaa mov r3.w, c2.x
bfaaaaaaacaaabacabaaaaoeaeaaaaaaaaaaaaaaaaaaaaaa neg r2.x, v1
abaaaaaaacaaabacacaaaaaaacaaaaaaacaaaaoeabaaaaaa add r2.x, r2.x, c2
adaaaaaaacaaapacacaaaaaaacaaaaaaadaaaaoeacaaaaaa mul r2, r2.x, r3
aaaaaaaaadaaahacabaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r3.xyz, c1
aaaaaaaaadaaaiacacaaaaaaabaaaaaaaaaaaaaaaaaaaaaa mov r3.w, c2.x
adaaaaaaafaaapacabaaaaaaaeaaaaaaadaaaaoeacaaaaaa mul r5, v1.x, r3
abaaaaaaacaaapacafaaaaoeacaaaaaaacaaaaoeacaaaaaa add r2, r5, r2
bcaaaaaaadaaabacaaaaaakeacaaaaaaaaaaaakeacaaaaaa dp3 r3.x, r0.xyzz, r0.xyzz
akaaaaaaadaaabacadaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rsq r3.x, r3.x
adaaaaaaaaaaahacadaaaaaaacaaaaaaaaaaaakeacaaaaaa mul r0.xyz, r3.x, r0.xyzz
bfaaaaaaafaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa neg r5.x, r1.x
ckaaaaaaafaaapacafaaaaaaacaaaaaaacaaaappabaaaaaa slt r5, r5.x, c2.w
acaaaaaaaeaaapacacaaaappabaaaaaaacaaaaoeacaaaaaa sub r4, c2.w, r2
adaaaaaaaeaaapacaeaaaaoeacaaaaaaafaaaaoeacaaaaaa mul r4, r4, r5
abaaaaaaacaaapacaeaaaaoeacaaaaaaacaaaaoeacaaaaaa add r2, r4, r2
aaaaaaaaadaaaeacadaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r3.z, c3
aaaaaaaaadaaadacadaaaaffabaaaaaaaaaaaaaaaaaaaaaa mov r3.xy, c3.y
bcaaaaaaaaaaabacaaaaaakeacaaaaaaadaaaakeacaaaaaa dp3 r0.x, r0.xyzz, r3.xyzz
abaaaaaaaaaaabacaaaaaaaaacaaaaaaadaaaappabaaaaaa add r0.x, r0.x, c3.w
adaaaaaaaaaaapacacaaaaoeacaaaaaaaaaaaaaaacaaaaaa mul r0, r2, r0.x
bfaaaaaaafaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa neg r5.x, r1.x
ckaaaaaaafaaapacafaaaaaaacaaaaaaacaaaappabaaaaaa slt r5, r5.x, c2.w
acaaaaaaaeaaapacacaaaaoeacaaaaaaaaaaaaoeacaaaaaa sub r4, r2, r0
adaaaaaaaeaaapacaeaaaaoeacaaaaaaafaaaaoeacaaaaaa mul r4, r4, r5
abaaaaaaaaaaapacaeaaaaoeacaaaaaaaaaaaaoeacaaaaaa add r0, r4, r0
bfaaaaaaafaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa neg r5.x, r1.x
ckaaaaaaaeaaaiacafaaaaaaacaaaaaaacaaaappabaaaaaa slt r4.w, r5.x, c2.w
acaaaaaaafaaaiacaaaaaappacaaaaaaacaaaaaaabaaaaaa sub r5.w, r0.w, c2.x
adaaaaaaaaaaaiacafaaaappacaaaaaaaeaaaappacaaaaaa mul r0.w, r5.w, r4.w
abaaaaaaaaaaaiacaaaaaappacaaaaaaacaaaaaaabaaaaaa add r0.w, r0.w, c2.x
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { }
ConstBuffer "$Globals" 80 // 48 used size, 7 vars
Vector 16 [_Cold] 4
Vector 32 [_Warm] 4
BindCB "$Globals" 0
// 18 instructions, 2 temp regs, 0 temp arrays:
// ALU 14 float, 0 int, 1 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_1
eefiecedddfmepoaamhinfiolamnfhemangfhfnpabaaaaaanmaeaaaaaeaaaaaa
daaaaaaaamacaaaadiaeaaaakiaeaaaaebgpgodjneabaaaaneabaaaaaaacpppp
keabaaaadaaaaaaaabaaceaaaaaadaaaaaaadaaaaaaaceaaaaaadaaaaaaaabaa
acaaaaaaaaaaaaaaaaacppppfbaaaaafacaaapkaaaaaaaaaaaaaaadpaaaaiadp
aaaaaalpfbaaaaafadaaapkapidadadppidadadppfolgkdoaaaaaaaafbaaaaaf
aeaaapkadddddddpjkjjjjdoaaaaaaaaaaaaaaaabpaaaaacaaaaaaiaaaaacdla
bpaaaaacaaaaaaiaabaaahlaafaaaaadaaaaciiaaaaafflaaaaafflaaeaaaaae
aaaacbiaaaaaaalaaaaaaalaaaaappiaacaaaaadaaaacbiaaaaaaaiaacaappka
ahaaaaacaaaacbiaaaaaaaiaagaaaaacaaaaceiaaaaaaaiaabaaaaacaaaacdia
aaaaoelaceaaaaacabaachiaaaaaoeiaaiaaaaadaaaacbiaabaaoeiaadaaoeka
aeaaaaaeaaaacbiaaaaaaaiaaeaaaakaaeaaffkaacaaaaadaaaaaciaabaaaalb
acaakkkaafaaaaadaaaaaoiaaaaaffiaaaaablkaaeaaaaaeaaaacoiaabaaaala
abaablkaaaaaoeiaafaaaaadaaaachiaaaaaaaiaaaaabliafkaaaaaeaaaaaiia
aaaaoelaaaaaoelaacaaaakaahaaaaacaaaaaiiaaaaappiaagaaaaacaaaaaiia
aaaappiaacaaaaadaaaaaiiaaaaappibacaaffkafiaaaaaeabaaahiaaaaappia
aaaaoeiaacaaaakafiaaaaaeabaaaiiaaaaappiaacaakkkaacaaaakaabaaaaac
aaaiapiaabaaoeiappppaaaafdeieefcceacaaaaeaaaaaaaijaaaaaafjaaaaae
egiocaaaaaaaaaaaadaaaaaagcbaaaaddcbabaaaabaaaaaagcbaaaadbcbabaaa
acaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaapaaaaahbcaabaaa
aaaaaaaaegbabaaaabaaaaaaegbabaaaabaaaaaaaaaaaaahccaabaaaaaaaaaaa
akaabaaaaaaaaaaaabeaaaaaaaaaaalpelaaaaafbcaabaaaaaaaaaaaakaabaaa
aaaaaaaabnaaaaahbcaabaaaaaaaaaaaabeaaaaaaaaaaadpakaabaaaaaaaaaaa
elaaaaafecaabaaaabaaaaaabkaabaaaaaaaaaaadgaaaaafdcaabaaaabaaaaaa
egbabaaaabaaaaaabaaaaaahccaabaaaaaaaaaaaegacbaaaabaaaaaaegacbaaa
abaaaaaaeeaaaaafccaabaaaaaaaaaaabkaabaaaaaaaaaaadiaaaaahocaabaaa
aaaaaaaafgafbaaaaaaaaaaaagajbaaaabaaaaaabaaaaaakccaabaaaaaaaaaaa
jgahbaaaaaaaaaaaaceaaaaapidadadppidadadppfolgkdoaaaaaaaadcaaaaaj
ccaabaaaaaaaaaaabkaabaaaaaaaaaaaabeaaaaadddddddpabeaaaaajkjjjjdo
aaaaaaaiecaabaaaaaaaaaaaakbabaiaebaaaaaaacaaaaaaabeaaaaaaaaaiadp
diaaaaaihcaabaaaabaaaaaakgakbaaaaaaaaaaaegiccaaaaaaaaaaaabaaaaaa
dcaaaaakhcaabaaaabaaaaaaagbabaaaacaaaaaaegiccaaaaaaaaaaaacaaaaaa
egacbaaaabaaaaaadiaaaaahhcaabaaaabaaaaaafgafbaaaaaaaaaaaegacbaaa
abaaaaaadgaaaaaficaabaaaabaaaaaaabeaaaaaaaaaiadpabaaaaahpccabaaa
aaaaaaaaagaabaaaaaaaaaaaegaobaaaabaaaaaadoaaaaabejfdeheogiaaaaaa
adaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaa
fmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadadaaaafmaaaaaaabaaaaaa
aaaaaaaaadaaaaaaacaaaaaaahabaaaafdfgfpfaepfdejfeejepeoaafeeffied
epepfceeaaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3"
}

}

#LINE 110
  
		}
	} 
	Fallback "Diffuse"
}