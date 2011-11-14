#region usings
using System;
using System.ComponentModel.Composition;
using System.Runtime.InteropServices;

using SlimDX;
using SlimDX.Direct3D9;
using VVVV.Core.Logging;
using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.PluginInterfaces.V2.EX9;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;
using VVVV.Utils.SlimDX;

#endregion usings

//here you can change the vertex type
using VertexType = VVVV.Utils.SlimDX.TexturedVertex;

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "GenerateBuffer", Category = "Particles", Help = "Basic template which creates a texture", Tags = "")]
	#endregion PluginInfo
	public class ParticlesGenerateBufferNode : DXTextureOutPluginBase, IPluginEvaluate
	{
		#region fields & pins

		[Input("Particle Count", DefaultValue = 16)]
		IDiffSpread<int> FPinInParticleCount;

		[Input("Generate")]
		ISpread<bool> FPinInGenerate;
		
		[Output("Texture Dimension")]
		ISpread<int> FPinOutTextureDimension;
		
		[Import()]
		ILogger FLogger;

		//track the current texture slice
		int FDimension;
		int FCount;
		
		int FCurrentSlice;

		#endregion fields & pins

		// import host and hand it to base constructor
		[ImportingConstructor()]
		public ParticlesGenerateBufferNode(IPluginHost host) : base(host)
		{
		}

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			SetSliceCount(1);

			//recreate texture if resolution was changed
			if (FPinInParticleCount.IsChanged)
			{
				int PowOf2 = (int)(Math.Log(Math.Sqrt(FPinInParticleCount[0]))/Math.Log(2.0d));
				FDimension = (int)Math.Pow(2.0d, (double)PowOf2);
				
				FCount = FDimension*FDimension;
				
				FPinOutTextureDimension[0] = FDimension;
				//set new texture size
			}

			//update texture
			if (FPinInGenerate[0])
			{
				Reinitialize();
				Update();
			}

		}

		//this method gets called, when Reinitialize() was called in evaluate,
		//or a graphics device asks for its data
		protected override Texture CreateTexture(int Slice, Device device)
		{
			FLogger.Log(LogType.Debug, "Creating new texture at slice: " + Slice);
			return TextureUtils.CreateTexture(device, FDimension, FDimension);
		}

		//this method gets called, when Update() was called in evaluate,
		//or a graphics device asks for its texture, here you fill the texture with the actual data
		//this is called for each renderer, careful here with multiscreen setups, in that case
		//calculate the pixels in evaluate and just copy the data to the device texture here
		unsafe protected override void UpdateTexture(int Slice, Texture texture)
		{
			FCurrentSlice = Slice;
			TextureUtils.Fill32BitTexInPlace(texture, FillTexure);
		}

		//this is a pixelshader like method, which we pass to the fill function
		unsafe private void FillTexure(uint* data, int row, int col, int width, int height)
		{
			//a pixel is just a 32-bit unsigned int value
			var pixel = UInt32Utils.fromARGB(255, wave, wave, wave);

			//copy pixel into texture
			TextureUtils.SetPtrVal2D(data, pixel, row, col, width);
		}
	}
}
