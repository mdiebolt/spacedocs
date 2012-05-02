TOOLKIT_DIR = "jsdoc-toolkit/"

desc "Build docs"
task :doc do
  cmd = "java -jar #{TOOLKIT_DIR}jsrun.jar #{TOOLKIT_DIR}app/run.js projects/1/game.js -c=jsdoc.conf -d=projects/1/docs/ -n -s"
  system(cmd)
end