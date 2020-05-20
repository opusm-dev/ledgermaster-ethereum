module.exports = {
  action: function() {
    console.log.call(console.log, '\t[ACTION]', ...arguments);
  }
};