import FileUpload from "./FileUpload";
import UploadButton from "./UploadButton";

export default React.createClass({
  getInitialState: function() {
    return {files: []};
  },
  getFileArray: function(files) {
    let fileArr = [];
    const len = files.length;
    for (let i = 0; i < len; i++) {
      fileArr[i] = files[i];
    }
    return fileArr;
  },
  handleFilesSelected: function(event) {
    const files = this.getFileArray(event.target.files);
    this.setState({files: files});
  },
  handleDrop: function(event) {
    const files = this.getFileArray(event.dataTransfer.files);
    this.setState({files: files});
  },
  render: function() {
    return (
      <div>
        <UploadButton onDrop={this.handleDrop} />
        <input id='browse' className='hidden' type='file' onChange={this.handleFilesSelected} multiple />
        <table className='table'>
          <thead>
            <tr>
              <td style={{width: '30%'}}></td>
              <td style={{width: '70%'}}></td>
            </tr>
          </thead>
          <tbody id="files">
            {
              this.state.files.map(function(file, ind) {
                return (
                  <FileUpload key={file.name} name={file.name} file={file} />
                );
              }, this)
            }
          </tbody>
        </table>
      </div>
    );
  }
});
