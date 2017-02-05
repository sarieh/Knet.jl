using Knet: cuda10

function cuda10src(f, j=f, ex="$f(xi,s)"; BLK=256, THR=256)
  sprint() do s
    for (T,F) in [("float","$(f)_32"),("double","$(f)_64")]
        print(s,
  """
__global__ void _$(F)_10(int n, $T *x, $T s, $T *y) {
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  while (i < n) {
    $T xi = x[i];
    y[i] = $ex;
    i += blockDim.x * gridDim.x;
  }
}

extern "C" {
  void $(F)_10(int n, $T *x, $T s, $T *y) {
    _$(F)_10<<<$BLK,$THR>>>(n,x,s,y);
  }
}
  """)
    end
  end
end

for a in cuda10
    isa(a,Tuple) || (a=(a,))
    print(cuda10src(a...))
end