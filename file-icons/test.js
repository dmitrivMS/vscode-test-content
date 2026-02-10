const EventEmitter = require('events');

class TaskQueue extends EventEmitter {
    constructor(concurrency = 3) {
        super();
        this.concurrency = concurrency;
        this.running = 0;
        this.queue = [];
    }

    enqueue(taskFn) {
        return new Promise((resolve, reject) => {
            this.queue.push({ taskFn, resolve, reject });
            this._processNext();
        });
    }

    _processNext() {
        while (this.running < this.concurrency && this.queue.length > 0) {
            const { taskFn, resolve, reject } = this.queue.shift();
            this.running++;
            this.emit('taskStart', this.running);

            taskFn()
                .then(resolve)
                .catch(reject)
                .finally(() => {
                    this.running--;
                    this.emit('taskComplete', this.running);
                    this._processNext();
                });
        }
    }
}

module.exports = TaskQueue;
