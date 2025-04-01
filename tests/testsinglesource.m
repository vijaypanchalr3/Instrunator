source = testSource(24);
lockin = testlockin(7);

function out = sinnn(x,y)
    out = sin(x^2+y^2);
end

sampler = testsampler(lockin, 0.3, 0.02,0.01, "../../");
% sampler.singleSource(source, [0,2,0.1], 2);
sampler.doubleSource(source, source, [0,2,0.1],[0,2,0.1], type=0, filename='test.asc');