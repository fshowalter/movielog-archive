const chalk = require('chalk');
const { reportDownloadProgress } = require('./reportDownloadProgress');

const dependencies = {
  reportDownloadProgress
};

const onPathReady = path => {
  global.console.log(chalk.dim('Downloading to ') + chalk.white(path) + chalk.dim('...'));
};

const onDone = () => {
  global.console.log(chalk.bold.green('All files downloaded!'));
};

const createReporter = orchestrator => {
  orchestrator.on('pathReady', onPathReady);
  orchestrator.on('startFile', dependencies.reportDownloadProgress);
  orchestrator.on('done', onDone);

  return orchestrator;
};

module.exports = { createReporter, dependencies };
