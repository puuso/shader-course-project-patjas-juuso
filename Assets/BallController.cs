using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class BallController : MonoBehaviour
{
    [SerializeField] private Material ProximityMaterial;

    private static int PlayerPosID = Shader.PropertyToID(name: "_PlayerPosition");
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 movement = Vector3.zero;

        if (Input.GetKey(KeyCode.A))
            movement += Vector3.left;
        if (Input.GetKey(KeyCode.W))
            movement += Vector3.forward;
        if (Input.GetKey(KeyCode.S))
            movement += Vector3.back;
        if (Input.GetKey(KeyCode.D))
            movement += Vector3.right;

        transform.Translate(translation:Time.deltaTime * 5 * movement.normalized, relativeTo:Space.World);

        ProximityMaterial.SetVector(PlayerPosID, (Vector4)transform.position);
    }
}
