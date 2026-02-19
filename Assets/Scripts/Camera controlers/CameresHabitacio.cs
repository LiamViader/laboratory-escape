using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using UnityEngine.Rendering.Universal;


public class CameresHabitacio : MonoBehaviour
{
    [SerializeField]
    private List<CinemachineVirtualCamera> _cameres;
    private int act = 0;
    [SerializeField] bool useSecurityCamShader = true;
    [SerializeField] string securityCamFeaturePassName;
    [SerializeField] private UniversalRendererData universalRendererData;

    // Start is called before the first frame update
    void Start()
    {
        _cameres.ForEach(cam => {
            if(cam.LookAt==null) cam.LookAt = ControlPersonatge._instance.transform;
            cam.gameObject.SetActive(false);
        });
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.TryGetComponent<ControlPersonatge>(out ControlPersonatge component))
        {
            GestorHabsSingleton._instance.CanviarHab(this, new CinemachineBlendDefinition(CinemachineBlendDefinition.Style.Cut, 1));
        }
    }

    public CinemachineVirtualCamera Activar()
    {
        if (!useSecurityCamShader) DeActivateSecurityCamShader();
        act = 0;
        _cameres[act].gameObject.SetActive(true);
        return _cameres[act];
    }

    public void Desactivar()
    {
        if (!useSecurityCamShader) ActivateSecurityCamShader();
        _cameres[act].gameObject.SetActive(false);
    }

    public CinemachineVirtualCamera SeguentCam()
    {
        _cameres[act].gameObject.SetActive(false);
        act++;
        if (act >= _cameres.Count) act = 0;
        _cameres[act].gameObject.SetActive(true);
        return _cameres[act];
    }

    public CinemachineVirtualCamera AnteriorCam()
    {
        _cameres[act].gameObject.SetActive(false);
        act--;
        if (act < 0) act = _cameres.Count-1;
        _cameres[act].gameObject.SetActive(true);
        return _cameres[act];
    }

    public static int getIgnoreMask()
    {
        return ~LayerMask.GetMask("CamerasZone");
    }


    private void ActivateSecurityCamShader()
    {
        if (universalRendererData == null)
        {
            return;
        }
        foreach (var feature in universalRendererData.rendererFeatures)
        {
            if (feature != null && feature.name == securityCamFeaturePassName)
            {
                feature.SetActive(true);
                return;
            }
        }
    }

    private void DeActivateSecurityCamShader()
    {
        if (universalRendererData == null)
        {
            return;
        }
        foreach (var feature in universalRendererData.rendererFeatures)
        {
            if (feature != null && feature.name == securityCamFeaturePassName)
            {
                feature.SetActive(false);
                return;
            }
        }
    }

}
