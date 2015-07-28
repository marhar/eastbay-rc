var c = document.getElementById('canvas'),
	ctx = c.getContext('2d'),

	copter = new Copter(ctx, 250, 500),

	copterYOut = document.getElementById('copter-y'),
	copterThrOut = document.getElementById('copter-thr');
	

c.width = 500;
c.height = 500;

(function loop() {
	requestAnimationFrame(loop);

	ctx.clearRect(0, 0, 500, 500);

	copter.update();

	copterYOut.textContent = Math.round(500 - copter.y);
	copterThrOut.textContent = copter.throttle;

}());

document.getElementsByTagName('input')[0].addEventListener('change', function() {
	copter.controller.kp = parseFloat(this.value);
}, false);

document.getElementsByTagName('input')[1].addEventListener('change', function() {
	copter.controller.ki = parseFloat(this.value);
}, false);

document.getElementsByTagName('input')[2].addEventListener('change', function() {
	copter.controller.kd = parseFloat(this.value);
}, false);