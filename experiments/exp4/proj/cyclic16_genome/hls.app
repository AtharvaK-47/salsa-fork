<AutoPilot:project xmlns:AutoPilot="com.autoesl.autopilot.project" projectType="C/C++" top="fenwick_top" name="cyclic16_genome" ideType="classic">
    <files>
        <file name="fenwick.cpp" sc="0" tb="false" cflags="-DVARIANT=1" csimflags="" blackbox="false"/>
        <file name="C:/gitrepos/salsa-fork/experiments/exp4/tb.cpp" sc="0" tb="1" cflags="-DVARIANT=1 -Wno-unknown-pragmas" csimflags="" blackbox="false"/>
        <file name="../fenwick.cpp" sc="0" tb="1" cflags="-DVARIANT=1 -Wno-unknown-pragmas" csimflags="" blackbox="false"/>
    </files>
    <solutions>
        <solution name="sol" status=""/>
    </solutions>
    <Simulation argv="C:/gitrepos/salsa-fork/experiments/exp4/traces/genome.bin">
        <SimFlow name="csim" setup="false" optimizeCompile="false" clean="false" ldflags="" mflags=""/>
    </Simulation>
</AutoPilot:project>
