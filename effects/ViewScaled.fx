//@author: elliotwoods
//@help: Preview a floating point texture
//@tags:
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;

    //transform position
	PosO.xy *= 2;
    Out.Pos = mul(PosO, tW);
    
    //transform texturecoordinates
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float InputMin = -1.0f;
float InputMax = 1.0f;
float DeadZone = 0.0f;

float4 PS(vs2ps In): COLOR
{
    float4 col = tex2D(Samp, In.TexCd);
	col -= InputMin;
	col /= InputMax - InputMin;
	col *= abs(col) > DeadZone;
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TScaled
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}
