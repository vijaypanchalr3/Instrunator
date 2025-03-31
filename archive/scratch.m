t = 0;
y = 0;

figure;
h = animatedline('Color', 'r', 'LineWidth', 1.5);
xlabel('Time');
ylabel('Value');
grid on;

while t < 10
    t = t + 0.1;
    y = sin(t);  
    addpoints(h, t, y);  % Add new points
    drawnow;  % Update plot
    pause(0.1);
end
