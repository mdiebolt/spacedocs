TOOLKIT_DIR = "source/jsdoc-toolkit/"

desc "Build docs"
task :doc do
  cmd = "java -jar #{TOOLKIT_DIR}jsrun.jar #{TOOLKIT_DIR}app/run.js projects/1/game.js -c=jsdoc.conf -d=source/docs/ -n -s"
  system(cmd)
end