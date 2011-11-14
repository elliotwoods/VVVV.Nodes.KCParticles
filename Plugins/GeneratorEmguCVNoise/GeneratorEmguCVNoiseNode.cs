#region using
using System.ComponentModel.Composition;
using System.Drawing;
using System;

using Emgu.CV;
using Emgu.CV.Structure;
using VVVV.Core.Logging;
using VVVV.PluginInterfaces.V2;
using System.Collections.Generic;
#endregion

namespace VVVV.Nodes.EmguCV
{
	public class TemplateGeneratorInstance : IGeneratorInstance
	{
		string FLoadedImage = "";
		Size FSize = new Size(32,32);
		float FRadius = 1;
		
		Random FRandom = new Random();
		public override bool NeedsThread()
		{
			return false;
		}

		public void Refresh()
		{
			FOutput.Image.Initialise(FSize, TColourFormat.RGBA32F);
			FillRandomValues();
		}
		
		private unsafe void FillRandomValues()
		{
			float* xyzt = (float*) FOutput.Data.ToPointer();
			
			int width = FSize.Width;
			int height = FSize.Height;
			for (int i=0; i<width*height; i++)
			{
				*xyzt++ = ((float)FRandom.NextDouble())*0.5f * FRadius;
				*xyzt++ = ((float)FRandom.NextDouble())*0.5f * FRadius;
				*xyzt++ = ((float)FRandom.NextDouble())*0.5f * FRadius;
				*xyzt = 0;
			}
		}
	}

	#region PluginInfo
	[PluginInfo(Name = "Noise", Category = "EmguCV", Version = "Generator", Help = "Template node for a threaded filter", Author = "", Credits = "", Tags = "")]
	#endregion PluginInfo
	public class GeneratorEmguCVNoiseNode : IGeneratorNode<TemplateGeneratorInstance>
	{
		#region fields & pins
		[Input("Refresh", IsBang = true)]
		ISpread<bool> FPinInRefresh;
		
		[Import()]
		ILogger FLogger;
		#endregion fields&pins

		[ImportingConstructor()]
		public GeneratorEmguCVNoiseNode()
		{

		}

		protected override void Update(int InstanceCount)
		{
			for (int i = 0; i < InstanceCount; i++)
				if (FPinInRefresh[i])
					FProcessor[i].Refresh();
		}
	}
}
