
clout.exec('tosca.lib.utils');

var nodeTemplateName = puccini.arguments.nodeTemplate;
var name = puccini.arguments.name;
var value = puccini.arguments.value;

puccini.log.infof('execution for node template %q, setting output: %s -> %s', nodeTemplateName, name, value);

if (tosca.setOutputValue(name, value))
	puccini.write(clout);
