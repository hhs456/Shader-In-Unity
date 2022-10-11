using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
 
public class Mirror : MonoBehaviour {
    public Cubemap cubeMap;
    public Camera cam;
    Material curmat;
    // Use this for initialization
    void Start() {
        InvokeRepeating("Change", 1, 0.1f);
        curmat = gameObject.GetComponent<Renderer>().material;
        if (curmat == null) {
            Debug.Log("cw");
        }

    }

    void Change() {
        cam.transform.rotation = Quaternion.identity;
        cam.RenderToCubemap(cubeMap);
        curmat.SetTexture("_Cubemap", cubeMap);
    }

}