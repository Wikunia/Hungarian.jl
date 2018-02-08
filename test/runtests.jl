using Hungarian
using Base.Test

@testset "simple examples" begin
    A = [ 0.891171  0.0320582   0.564188  0.8999    0.620615;
          0.166402  0.861136    0.201398  0.911772  0.0796335;
          0.77272   0.782759    0.905982  0.800239  0.297333;
          0.561423  0.170607    0.615941  0.960503  0.981906;
          0.748248  0.00799335  0.554215  0.745299  0.42637]

    assign, cost = @inferred hungarian(A)
    @test assign == [2, 3, 5, 1, 4]

    B = [ 24     1     8;
           5     7    14;
           6    13    20;
          12    19    21;
          18    25     2]

    assign, cost = hungarian(B)
    @test assign == [2, 1, 0, 0, 3]
    @test cost == 8

    assign, cost = hungarian(B')
    @test assign == [2, 1, 5]
    @test cost == 8

    assign, cost = hungarian(ones(5,5) - eye(5))
    @test assign == [1, 2, 3, 4, 5]
    @test cost == 0
end

@testset "test against Munkres.jl" begin
    using Munkres
    @testset "300x300" begin
        A = rand(300,300)
        assignH, costH = hungarian(A)
        assignM = munkres(A)
        @test assignH == assignM
    end
    @testset "200x400" begin
        A = rand(200,400)
        assignH, costH = hungarian(A)
        assignM = munkres(A)
        @test assignH == assignM
    end
    @testset "500x250" begin
        A = rand(500,250)
        assignH, costH = hungarian(A)
        assignM = munkres(A)
        @test assignH == assignM
    end
    @testset "50x50s" begin
        for i = 1:100
            A = rand(50,50)
            assignH, costH = hungarian(A)
            assignM = munkres(A)

            costM = 0
            for i in zip(1:size(A,1), assignM)
                if i[2] != 0
                    costM += A[i...]
                end
            end

            @test assignH == assignM
            @test costH == costM
        end
    end
end

@testset "forbidden edges" begin
    # result checked against Python package munkres: https://github.com/bmc/munkres/blob/master/munkres.py
    # Python code:
    #   m = Munkres()
    #   matrix = [[DISALLOWED, 1, 1], [1, 0, 1], [1, 1, 0]]
    #   m.compute(matrix)
    # Result: [(0, 1), (1, 0), (2, 2)]
    using Missings
    A = Union{Int, Missing}[missing 1 1; 1 0 1; 1 1 0]
    assign, cost = hungarian(A)
    @test assign == [2, 1, 3]
    @test cost == 2
end

@testset "issue #2" begin
    A = [0   1   2   3   4   5   6   7   8   9   1   2   3   4   5   6   7   8   9  10   2   3   4   5   6   7   8   9  10  11;
         1   0   1   2   3   4   5   6   7   8   2   1   2   3   4   5   6   7   8   9   3   2   3   4   5   6   7   8   9  10;
         2   1   0   1   2   3   4   5   6   7   3   2   1   2   3   4   5   6   7   8   4   3   2   3   4   5   6   7   8   9;
         3   2   1   0   1   2   3   4   5   6   4   3   2   1   2   3   4   5   6   7   5   4   3   2   3   4   5   6   7   8;
         4   3   2   1   0   1   2   3   4   5   5   4   3   2   1   2   3   4   5   6   6   5   4   3   2   3   4   5   6   7;
         5   4   3   2   1   0   1   2   3   4   6   5   4   3   2   1   2   3   4   5   7   6   5   4   3   2   3   4   5   6;
         6   5   4   3   2   1   0   1   2   3   7   6   5   4   3   2   1   2   3   4   8   7   6   5   4   3   2   3   4   5;
         7   6   5   4   3   2   1   0   1   2   8   7   6   5   4   3   2   1   2   3   9   8   7   6   5   4   3   2   3   4;
         8   7   6   5   4   3   2   1   0   1   9   8   7   6   5   4   3   2   1   2  10   9   8   7   6   5   4   3   2   3;
         9   8   7   6   5   4   3   2   1   0  10   9   8   7   6   5   4   3   2   1  11  10   9   8   7   6   5   4   3   2;
         1   2   3   4   5   6   7   8   9  10   0   1   2   3   4   5   6   7   8   9   1   2   3   4   5   6   7   8   9  10;
         2   1   2   3   4   5   6   7   8   9   1   0   1   2   3   4   5   6   7   8   2   1   2   3   4   5   6   7   8   9;
         3   2   1   2   3   4   5   6   7   8   2   1   0   1   2   3   4   5   6   7   3   2   1   2   3   4   5   6   7   8;
         4   3   2   1   2   3   4   5   6   7   3   2   1   0   1   2   3   4   5   6   4   3   2   1   2   3   4   5   6   7;
         5   4   3   2   1   2   3   4   5   6   4   3   2   1   0   1   2   3   4   5   5   4   3   2   1   2   3   4   5   6;
         6   5   4   3   2   1   2   3   4   5   5   4   3   2   1   0   1   2   3   4   6   5   4   3   2   1   2   3   4   5;
         7   6   5   4   3   2   1   2   3   4   6   5   4   3   2   1   0   1   2   3   7   6   5   4   3   2   1   2   3   4;
         8   7   6   5   4   3   2   1   2   3   7   6   5   4   3   2   1   0   1   2   8   7   6   5   4   3   2   1   2   3;
         9   8   7   6   5   4   3   2   1   2   8   7   6   5   4   3   2   1   0   1   9   8   7   6   5   4   3   2   1   2;
        10   9   8   7   6   5   4   3   2   1   9   8   7   6   5   4   3   2   1   0  10   9   8   7   6   5   4   3   2   1;
         2   3   4   5   6   7   8   9  10  11   1   2   3   4   5   6   7   8   9  10   0   1   2   3   4   5   6   7   8   9;
         3   2   3   4   5   6   7   8   9  10   2   1   2   3   4   5   6   7   8   9   1   0   1   2   3   4   5   6   7   8;
         4   3   2   3   4   5   6   7   8   9   3   2   1   2   3   4   5   6   7   8   2   1   0   1   2   3   4   5   6   7;
         5   4   3   2   3   4   5   6   7   8   4   3   2   1   2   3   4   5   6   7   3   2   1   0   1   2   3   4   5   6;
         6   5   4   3   2   3   4   5   6   7   5   4   3   2   1   2   3   4   5   6   4   3   2   1   0   1   2   3   4   5;
         7   6   5   4   3   2   3   4   5   6   6   5   4   3   2   1   2   3   4   5   5   4   3   2   1   0   1   2   3   4;
         8   7   6   5   4   3   2   3   4   5   7   6   5   4   3   2   1   2   3   4   6   5   4   3   2   1   0   1   2   3;
         9   8   7   6   5   4   3   2   3   4   8   7   6   5   4   3   2   1   2   3   7   6   5   4   3   2   1   0   1   2;
        10   9   8   7   6   5   4   3   2   3   9   8   7   6   5   4   3   2   1   2   8   7   6   5   4   3   2   1   0   1;
        11  10   9   8   7   6   5   4   3   2  10   9   8   7   6   5   4   3   2   1   9   8   7   6   5   4   3   2   1   0]

    B = [ 0 126   0   3 224   0   0 241  21 175 133   0   0 162   0   0   0   0 155   0   0   0 114 243   0  44  48  94  43 225;
        126   0   0   0   0 137  14   0   0  13   0 245   0 128  16   0 239   0 108   0  28   0   0   0 111   0 232 144  35  44;
          0   0   0   0 242 180 151   0   0   0 183   0 127  26  10   0  99 131 155   6   0   0   0  29   0   0   0   0   0  45;
          3   0   0   0 231  15  17   0 159   0   0 125 138  44   0 210 133   0   0   0   0   0   0 150   0 207 232   0   0   0;
        224   0 242 231   0   0 196  71   0   0  64   0  26   0   0 198  94   0   0   0   0   0   0 176   0   0  31   0 105 114;
          0 137 180  15   0   0   0   0 204 169   0 247 195  96 121   0   0 203   0  68   0   0   0   0  51 214   0  23  24   0;
          0  14 151  17 196   0   0   0   0   0 188   0   0 210   0 132  11  59   0   0  37 238   0 150   0 136 108   0   0   0;
        241   0   0   0  71   0   0   0   0   0   0 156   0 178   0 143 208   0   0   0 115  73   0   0 167  91   0 209   0 111;
         21   0   0 159   0 204   0   0   0 206   0 149   0   0   0   0   0   0   0   0   0   0   0   0 201   0 210  36   4   0;
        175  13   0   0   0 169   0   0 206   0   5   0 127   0   0   0   0  40   0  20 218   0 112   0   0 164 146  50   0 236;
        133   0 183   0  64   0 188   0   0   5   0   0  12 120  74   0   0  74  25  58  86   0   0 190   0  81 162   3   0   0;
          0 245   0 125   0 247   0 156 149   0   0   0   0   1   0   0   0   0   0  39   0 110 151   0  68 197   0   0   0  89;
          0   0 127 138  26 195   0   0   0 127  12   0   0   0  96  52   0 182   1   0 104  82 146  64 189  17 231   0   0   0;
        162 128  26  44   0  96 210 178   0   0 120   1   0   0   0   0   0   0 123  84 127 198 159   8   0  61   0  61   0   0;
          0  16  10   0   0 121   0   0   0   0  74   0  96   0   0   0  93 216  44  12   0 229   0   0   0 141  21 114   0 157;
          0   0   0 210 198   0 132 143   0   0   0   0  52   0   0   0  98  13   0  69 242  22 193   0   0  36  16  80  47   0;
          0 239  99 133  94   0  11 208   0   0   0   0   0   0  93  98   0   0   0   0  93  95  81   0   0 234 126 170  23  40;
          0   0 131   0   0 203  59   0   0  40  74   0 182   0 216  13   0   0   0   0 119   0   0  18  79   0  17  49   0   0;
        155 108 155   0   0   0   0   0   0   0  25   0   1 123  44   0   0   0   0   0   0   0   0 139   0 147   0  28 133  82;
          0   0   6   0   0  68   0   0   0  20  58  39   0  84  12  69   0   0   0   0   0 236  86   0   0   0   0 172   0   7;
          0  28   0   0   0   0  37 115   0 218  86   0 104 127   0 242  93 119   0   0   0 183 214   0   0   0 100   0   0  60;
          0   0   0   0   0   0 238  73   0   0   0 110  82 198 229  22  95   0   0 236 183   0  75 113 209 211   0  87   0  61;
        114   0   0   0   0   0   0   0   0 112   0 151 146 159   0 193  81   0   0  86 214  75   0 140   0  49   0  44   7   0;
        243   0  29 150 176   0 150   0   0   0 190   0  64   8   0   0   0  18 139   0   0 113 140   0 203 232 214 121   0   0;
          0 111   0   0   0  51   0 167 201   0   0  68 189   0   0   0   0  79   0   0   0 209   0 203   0   0 153 200   0   0;
         44   0   0 207   0 214 136  91   0 164  81 197  17  61 141  36 234   0 147   0   0 211  49 232   0   0   0 115   0 103;
         48 232   0 232  31   0 108   0 210 146 162   0 231   0  21  16 126  17   0   0 100   0   0 214 153   0   0  62 159   0;
         94 144   0   0   0  23   0 209  36  50   3   0   0  61 114  80 170  49  28 172   0  87  44 121 200 115  62   0 229  90;
         43  35   0   0 105  24   0   0   4   0   0   0   0   0   0  47  23   0 133   0   0   0   7   0   0   0 159 229   0   0;
        225  44  45   0 114   0   0 111   0 236   0  89   0   0 157   0  40   0  82   7  60  61   0   0   0 103   0  90   0   0]

    M = kron(A,B)

    @time assignH, costH = hungarian(M)
    @time assignM = munkres(M)
    @test assignH == assignM
end

@testset "issue #9" begin
    A = UInt8[ 49 107  64  23 232 139  21  72 124 125 197 226  45  99 106;
              152 106  95 138 109 171  45  11 173  57 129 223   6 242 116;
              191 197  43 224 105 229  85 225 163 118  99 207 195 194  14;
              239 225 216  48 127 252 234 114   6  64  81 116 161  90  19;
              209 122  84 187 200 150 229  21 115 154 203 252 221 238 131;
              172 247 161 255 102 128 176  63  67 105 107 194 217 226 109;
                5  49  90 126  45 211 168 198 211 200  42  88 117 224 172;
              205 250 117 234  75 251  80  28 121  67  87 106 172 111  54;
              157  99 233  70  80 196 237   3  77 137  32 143 100 117 149;
              221  80 132 251 233 238  44 212 204  41 158 124 113  17 252;
              171   9 138 170  15 190 149  15 190  58 252 248  21 210 223;
               97 240  45 200  53  45  94 122  77  12 114  84 155  94  21;
                6 209 214  15  58  59  60 232  40 210  93  63  80  86  95;
               11 184 129 159 130 171 181  41 164  65 171  55 164  72 132;
               30 225 231 144 209 203  30 202 195 221  70  38 220  48 203]
    @test_broken begin
        assignH, costH = hungarian(A)
        assignM = munkres(A)
        assignH == assignM
    end
end
end
