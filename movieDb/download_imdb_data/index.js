const { createOrchestrator } = require('./createOrchestrator');
const { reportOrchestratorProgress } = require('./reportOrchestratorProgress');

const dependencies = {
  createOrchestrator,
  reportOrchestratorProgress
};

const downloadImdbData = async () => {
  const orchestrator = dependencies.createOrchestrator();

  return dependencies.reportOrchestratorProgress(orchestrator).start();
};

module.exports = { downloadImdbData, dependencies };
