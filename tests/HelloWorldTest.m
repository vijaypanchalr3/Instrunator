classdef HelloWorldTest < matlab.unittest.TestCase
    methods(Test)
        function testHelloWorld(testCase)
            testCase.verifyEqual(HelloWorld(), 'Hello, World!');
        end
    end
end