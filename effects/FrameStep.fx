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
texture TexX <string uiname="XYZT";>;
sampler SampX = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexX);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

//texture
texture TexV <string uiname="Velocity";>;
sampler SampV = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexV);          //apply a texture to the sampler
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
    Out.Pos = PosO;
    
    //transform texturecoordinates
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
struct XYZTV
{
	float4 xyzt : COLOR;
	float4 v : COLOR1;
};

float dt;

XYZTV PSHarmonic(vs2ps In)
{
	XYZTV state;
	state.xyzt = tex2D(SampX, In.TexCd);
	state.v = tex2D(SampV, In.TexCd);

	state.xyzt.xyz += state.v.xyz * dt;
	state.v.xyz -= state.xyzt.xyz * dt;
	return state;
}

float Gravity = 1.0;
XYZTV PSGravity(vs2ps In)
{
	XYZTV state;
	state.xyzt = tex2D(SampX, In.TexCd);
	state.v = tex2D(SampV, In.TexCd);

	state.xyzt.xyz += state.v.xyz * dt;
	state.v.y -= Gravity * dt;
	return state;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique THarmonic
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PSHarmonic();
    }
}

technique TGravity
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PSGravity();
    }
}
