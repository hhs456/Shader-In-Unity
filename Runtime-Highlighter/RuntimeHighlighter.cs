using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ToolKid.Shader {    
    public enum HighlightTiming {
        Never = 1,  //"Rendering.CompareFunction.Never" => Never pass depth or stencil test.    
        Visible = 2,//"Rendering.CompareFunction.Less" => Pass depth or stencil test when new value is less than old one.         
        Hidden = 7, //"Rendering.CompareFunction.GreaterEqual" => Pass depth or stencil test when new value is greater or equal than old one.    
        Always = 8  //"Rendering.CompareFunction.Always" => Always pass depth or stencil test.
    }
    public enum HighlightType {        
        Overall = 1,//"Rendering.CompareFunction.Never" => Never pass depth or stencil test.    
        Overlap = 4,//"Rendering.CompareFunction.LessEqual" => Pass depth or stencil test when new value is less or equal than old one.
        Outline = 8 //"Rendering.CompareFunction.Always" => Always pass depth or stencil test.
    }
}
