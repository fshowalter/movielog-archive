const { createOrchestrator } = require('./createOrchestrator');
const { createReporter } = require('./createReporter');

const dependencies = {
  createOrchestrator,
  reportOrchestratorProgress
};

const downloadImdbData = async () => {
  const orchestrator = dependencies.createOrchestrator();

  return dependencies.createReporter(orchestrator).start();
};

module.exports = { downloadImdbData, dependencies };
