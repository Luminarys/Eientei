// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in 'brunch-config.js'.
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from 'config.paths.watched'.
import 'deps/phoenix_html/web/static/js/phoenix_html';

// Import local files
//
// Local files can be imported directly using relative
// paths './socket' or full ones 'web/static/js/socket'.

// import socket from './socket'

// var paste = document.getElementById('paste');
// var pasteBtn = document.getElementById('paste-btn');
import UploadButton from "./UploadButton";
import FileSelector from "./FileSelector";

function dragNOP(evt) {
  evt.stopPropagation();
  evt.preventDefault();
}

function handleDragDrop(evt) {
  dragNOP(evt);
  for (let file of evt.dataTransfer.files) {
    const row = addRow(file);
    uploadFile(file, row);
  }
}

function uploadFiles() {
  // mfw no iterators
  const len = browse.files.length;
  for (let i = 0; i < len; i++) {
    const file = browse.files[i];
    const row = addRow(file);
    uploadFile(file, row);
  }
}

window.addEventListener('dragenter', dragNOP, false);
window.addEventListener('dragleave', dragNOP, false);
window.addEventListener('dragover', dragNOP, false);
window.addEventListener('drop', handleDragDrop, false);

// browse.addEventListener('change', uploadFiles);

// document.querySelector('.target').addEventListener('click', selectFiles);

ReactDOM.render(
  <UploadButton />,
  document.getElementById('uploadButton')
);

ReactDOM.render(
  <FileSelector />,
  document.getElementById('uploadForm')
);

/*
  paste.addEventListener('keydown', function() {
    pasteBtn.style.display = 'block';
  });
  pasteBtn.addEventListener('click', function(e) {
    e.preventDefault();
    var blob = new Blob([paste.value], {type: 'text/plain'});
    var file = new File([blob], 'paste.txt');
    var progress = addRow(file);
    uploadFile(file, progress);
  });
/**/
