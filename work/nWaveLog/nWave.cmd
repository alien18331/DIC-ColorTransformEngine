wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/home/yutongshen/HW5/work/CTE2_pre.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/test"
wvGetSignalClose -win $_nWave1
wvRestoreSignal -win $_nWave1 "/home/yutongshen/HW5/work/CTE2.rc" \
           -overWriteAutoAlias on
wvResizeWindow -win $_nWave1 111 167 1162 856
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoom -win $_nWave1 207681.792553 219159.662806
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 12531.960378 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 8081.357627 -snap {("G2" 5)}
wvSetCursor -win $_nWave1 10423.780128 -snap {("G2" 5)}
wvSetCursor -win $_nWave1 12239.157566 -snap {("G2" 5)}
wvSetCursor -win $_nWave1 12766.202628 -snap {("G2" 5)}
wvSetCursor -win $_nWave1 14230.216691 -snap {("G2" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 17860.971567 -snap {("G3" 0)}
wvSetCursor -win $_nWave1 16982.563129 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 13176.126566 -snap {("G3" 0)}
wvSetCursor -win $_nWave1 15284.306816 -snap {("G2" 3)}
wvSetCursor -win $_nWave1 16221.275817 -snap {("G2" 4)}
wvZoom -win $_nWave1 0.000000 16221.275817
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 7614.068241 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 6455.405682 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 7779.591463 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 12993.572976 -snap {("G2" 5)}
wvSetCursor -win $_nWave1 11834.910417 -snap {("G2" 5)}
