using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
public class GameOfLife : MonoBehaviour
{
    // Scripti voi vaihtaa inspectorissa dropdown valikon avulla aloitus seedi‰.
    public enum GameInit
    {
        RPentomino,
        Acorn,
        GosperGun,
        FullTexture
    }
    [SerializeField] private GameInit Seed;
    // Scriptin kuuluisi p‰ivitt‰‰ ulkoisen planen materiaalia vaihtamalla sen tekstuuria.
    [SerializeField] private Material PlaneMaterial;
    // Simuloitavan solun v‰ri‰ tulisi voida muuttaa ennen simulaation aloitusta.
    [SerializeField] private Color CellCol;
    [SerializeField] private ComputeShader Simulator;
    // Pelin ollessa k‰ynniss‰, scriptin tulisi yll‰pit‰‰ aikav‰li‰, jona simulaatiota p‰ivitet‰‰n,
    // eli kuinka nopeasti uusi generaatio tapahtuu.
    [SerializeField, Range(0f, 2f)] private float UpdateInterval;
    private float NextUpdate = 2f;
    // Tekstuurien koko on 512x512.
    private static readonly Vector2Int TexSize = new Vector2Int(512, 512);
    private RenderTexture State1;
    private RenderTexture State2;
    // Scriptill‰ on 2 vaihetta, update1 ja update2.
    // Scriptin kuuluisi voida vaihdella niiden v‰lill‰.
    // Scriptin tulisi myˆs pit‰‰ kirjaa, kummassa vaiheessa simulaatiota ollaan,
    // ja p‰‰tt‰‰ sen mukaan, kumpi vaihe suorittaa.
    private bool IsState1;
    private static int Update1Kernel;
    private static int Update2Kernel;

    private static int RPentominoKernel;
    private static int AcornKernel;
    private static int GunKernel;
    private static int FullKernel;

    // Property ID
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int CellColour = Shader.PropertyToID("CellColour");
    private static readonly int TextureSize = Shader.PropertyToID("TextureSize");
    private static readonly int State1Tex = Shader.PropertyToID("State1");
    private static readonly int State2Tex = Shader.PropertyToID("State2");

    void Start()
    {
        // Scriptin tulisi aluksi, kun peli k‰ynnistet‰‰n, luoda 2 RenderTexturea
        // default LDR asetuksilla, point filterill‰ ja enableRandomWrite = true.
        State1 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };
        State1.Create();

        State2 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };
        State2.Create();

        // Sen tulisi myˆs lˆyt‰‰ Compute Shaderin kaikki kernelit t‰ss‰ vaiheessa.
        Update1Kernel = Simulator.FindKernel("Update1");
        Update2Kernel = Simulator.FindKernel("Update2");
        RPentominoKernel = Simulator.FindKernel("InitRPentomino");
        AcornKernel = Simulator.FindKernel("InitAcorn");
        GunKernel = Simulator.FindKernel("InitGun");
        FullKernel = Simulator.FindKernel("InitFullTexture");

        // Compute Shaderiin tulisi liitt‰‰ t‰ss‰ vaiheessa kaikkiin kerneleihin tarvittavat tekstuurit
        // ja muut fieldit jotka eiv‰t p‰ivity suorituksen aikana.
        Simulator.SetTexture(Update1Kernel, State1Tex, State1);
        Simulator.SetTexture(Update1Kernel, State2Tex, State2);

        Simulator.SetTexture(Update2Kernel, State1Tex, State1);
        Simulator.SetTexture(Update2Kernel, State2Tex, State2);

        Simulator.SetTexture(RPentominoKernel, State1Tex, State1);
        Simulator.SetTexture(AcornKernel, State1Tex, State1);
        Simulator.SetTexture(GunKernel, State1Tex, State1);
        Simulator.SetTexture(FullKernel, State1Tex, State1);

        Simulator.SetVector(CellColour, CellCol);

        // bonus
        Simulator.SetVector(TextureSize, new Vector4(TexSize.x, TexSize.y));

        // Scriptin tulisi myˆs t‰ss‰ vaiheessa p‰‰tt‰‰,
        // mill‰ aloitus seedill‰ simulaatio aloitetaan, ja initialisoida simulaatio.

        switch (Seed)
        {
            case GameInit.RPentomino:
                Simulator.Dispatch(RPentominoKernel, TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case GameInit.Acorn:
                Simulator.Dispatch(AcornKernel, TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case GameInit.GosperGun:
                Simulator.Dispatch(GunKernel, TexSize.x / 8, TexSize.y / 8, 1);
                break;
            case GameInit.FullTexture:
                Simulator.Dispatch(FullKernel, TexSize.x / 8, TexSize.y / 8, 1);
                break;
            default:
                break;
        }
    }

    void Update()
    {
        // Pelin ollessa k‰ynniss‰, scriptin tulisi yll‰pit‰‰ aikav‰li‰, jona simulaatiota p‰ivitet‰‰n,
        // eli kuinka nopeasti uusi generaatio tapahtuu.
        if (Time.time < NextUpdate) return;
        // Scriptin tulisi myˆs pit‰‰ kirjaa, kummassa vaiheessa simulaatiota ollaan,
        // ja p‰‰tt‰‰ sen mukaan, kumpi vaihe suorittaa.
        IsState1 = !IsState1;
        if (IsState1)
            Simulator.Dispatch(Update1Kernel, TexSize.x / 8, TexSize.y / 8, 1);
        else
            Simulator.Dispatch(Update2Kernel, TexSize.x / 8, TexSize.y / 8, 1);
        // Scriptin kuuluisi myˆs p‰ivitt‰‰ esitykseen k‰ytetyn materiaalin tekstuuria
        // vaiheen mukaan (flipbook).
        //Debug.Log("update " + IsState1);
        PlaneMaterial.SetTexture(BaseMap, IsState1 ? State1 : State2);
        NextUpdate = Time.time + UpdateInterval;
    }


    // Kun scripti tuhotaan tai disabloidaan,
    // sen kuuluisi vapauttaa render texture muuttujat muistista.
    private void OnDisable()
    {
        State1.Release();
        State2.Release();
    }
    private void OnDestroy()
    {
        State1.Release();
        State2.Release();
    }
}