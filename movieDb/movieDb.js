const program = require('commander');

const { downloadImdbData } = require('./download_imdb_data');

program.version('0.0.1').description("Frank's Movielog");

program.command('update').action(async () => {
  const downloadPath = await downloadImdbData();
});

program.parse(process.argv);
