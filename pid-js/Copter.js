function Copter(ctx, x, y) {
	this.ctx = ctx; //canvas context
	this.x = x;
	this.y = y;
	this.targetY = 250;
	//this.speedX = 0;
	this.speedY = 0;
	this.throttle = 0;
	this.maxPower = 3;
	this.controller = new PIDController(0.5, 0, 0);
}

Copter.prototype.draw = function() {
	this.ctx.beginPath();
	this.ctx.fillRect(this.x - 5, this.y - 5, 10, 10);
	this.ctx.fill();
};

Copter.prototype.update = function() {
	//this.x += this.speedX;
	this.y += this.speedY;
	this.speedY += 1; // gravity

	this.throttle = this.controller.update(this.y, this.targetY) / 100;

	this.speedY -= this.maxPower * this.throttle;

	this.draw();
};