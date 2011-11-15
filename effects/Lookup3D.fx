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
float4x4 tWV: WORLDVIEW;        //the models world matrix

//texture
texture TexXYZT <string uiname="XYZT";>;
sampler SampXYZT = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexXYZT);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//Color Texture
texture Texture <string uiname="Colour Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Texture);          //apply a texture to the sampler
    MipFilter = linear;         //sampler states
    MinFilter = linear;
    MagFilter = linear;
};

float4x4 tTex;
//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
	float2 ID : TEXCOORD;
	float Size : PSIZE;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VSMesh(float4 PosO  : POSITION,
float2 ID : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;

	float4 TexCdx = float4(ID.x, ID.y, 0, 0);
	float4 XYZT = tex2Dlod(SampXYZT, TexCdx);
    //transform position
	float4 xyz = XYZT;
	xyz.w = 1;
	xyz += mul(PosO, tObject);
	
    Out.Pos = mul(xyz, tWVP);
	Out.ID = ID;
	Out.Size = 1;
	
    return Out;
}

float Scale = 0.1;
vs2ps VSPoint(float4 PosO  : POSITION,
float2 ID : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;

	float4 TexCdx = float4(ID.x, ID.y, 0, 0);
	float4 XYZT = tex2Dlod(SampXYZT, TexCdx);
    //transform position
	float4 xyz = XYZT;
	xyz.w = 1;
	
    Out.Pos = mul(xyz, tWVP);
	Out.ID = ID;
	
	
	float4 tr = float4(Scale, Scale, Scale, 1);
	float4 bl = -tr;
	
	tr.xyz += xyz.xyz;
	bl.xyz += xyz.xyz;
	
	Out.Size = Scale;//length(mul(tr, tWVP) - mul(bl, tWVP));
	
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
float4 PS(vs2ps In): COLOR
{
	float4 col = tex2D(Samp, mul(In.ID,tTex));
	col.a;
	col.rg *= In.ID;
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TMesh
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VSMesh();
        PixelShader  = compile ps_3_0 PS();
    }
}

technique TPoint
{
	pass P0
	{
		FillMode = POINT;
		PointScaleEnable = true;
		PointSpriteEnable = true;
		
		AlphaBlendEnable = true;
		VertexShader = compile vs_3_0 VSPoint();
        PixelShader  = compile ps_3_0 PS();
	}
}