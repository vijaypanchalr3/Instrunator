class Sampler:
    def __init__(self, eng):
        lockin = eng.testlockin(7)
        source = eng.testSource(24)
        sampler = eng.testsampler(lockin)
        # Call method on sampler instance, not on eng
        eng.singleSource(sampler, source, 0, 0.1, 3, nargout=0)

if __name__ == '__main__':
    import matlab.engine

    eng = matlab.engine.start_matlab()
    
    Sampler(eng)

    eng.quit()

