class Sampler:
    def __init__(self, eng):
        lockin = eng.testlockin(7)
        source = eng.testSource(24)
        sampler = eng.testsampler(lockin)
        sampler.ramp_for_singlesource(sampler, source, 0, 0.1, 3)

if __name__ == '__main__':
    import matlab.engine

    eng = matlab.engine.start_matlab()
    
    
    samp = Sampler()


    eng.quit()
