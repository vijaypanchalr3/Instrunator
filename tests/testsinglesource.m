source = testSource();
lockin = testlockin(7);

function out = sinnn(x,y)
    out = sin(x^2+y^2);
end

sampler = sampler(lockin,0.1);
sampler.singleSource(source, Voltage=[0,3,0.1], type=2, funcY=@sinnn);