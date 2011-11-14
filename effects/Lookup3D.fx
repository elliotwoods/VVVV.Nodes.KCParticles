//@author: elliotwoods
//@help: this is a very basic template. use it to start writing your own effects. if you want effects with lighting start from one of the GouraudXXXX or PhongXXXX effects
//@tags:
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms

float4x4 tObject <string uiname="Object Transform";>;
float4x4 tWVP: WORLDVIEWPROJECTION;        //the models world matrix

//texture
texture Tex <string uiname="XYZT";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
	float2 ID : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(float4 PosO  : POSITION,
float2 ID : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;

	float4 TexCdx = float4(ID.x, ID.y, 0, 0);
	float4 XYZT = tex2Dlod(Samp, TexCdx);
    //transform position
	float4 xyz = XYZT;
	xyz.w = 1;
	xyz += mul(PosO, tObject);
	
    Out.Pos = mul(xyz, tWVP);
	Out.ID = ID;
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
float4 PS(vs2ps In): COLOR
{
	float4 col = (float4)1;
	col.rg = In.ID;
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
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 PS();
    }
}
