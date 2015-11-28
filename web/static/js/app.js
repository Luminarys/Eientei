import 'deps/phoenix_html/web/static/js/phoenix_html';
import FileSelector from "./FileSelector";

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
