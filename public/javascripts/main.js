// JavaScript Document

function atualizar(obj) {
	var uf = obj.options[obj.selectedIndex].value;
	if (uf != '') document.location.href = document.location.href.replace(/\/[a-z]{0,2}\/?([0-9])?$/,'/' + uf + '/$1');
}
