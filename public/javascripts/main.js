// JavaScript Document

function atualizar(obj) {
	var uf = obj.options[obj.selectedIndex].value;
	if (uf != '') document.location.href = document.location.href.replace(/turno\/[a-z]{0,2}\/?([a-z-]+)?$/,'turno/' + uf + '/$1');
}
