export default React.createClass({
  getInitialState: function() {
    return {percent: 0, complete: false};
  },
  handleUploadProgress: function (event) {
    if (event.lengthComputable) {
      const progressPercent = Math.floor((event.loaded / event.total) * 100);
      this.setState({percent: progressPercent});
    }
  },
  handleUploadComplete: function(event) {
    const xhr = event.target;
    switch (xhr.status) {
      case 200:
        const resp = JSON.parse(xhr.responseText).file;
        if (resp.success) {
          this.setState({complete: true, message: resp.url, url: resp.url});
        } else {
          this.setState({complete: true, error: true, message: resp.reason});
        }
        break;
      case 413:
        this.setState({complete: true, error: true, message: "I-it's too big Onii-chan! Use a smaller file!"});
        break;
      case 429:
        this.setState({complete: true, error: true, message: "I-it's too much Onii-chan! Stop uploading so much!"});
        break;
      default:
        this.setState({complete: true, error: true, message: "S-something went wrong!!"});
        break;
    }
  },
  componentDidMount: function() {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/upload');

    xhr.addEventListener('load', this.handleUploadComplete, false);
    xhr.upload.onprogress = this.handleUploadProgress;

    const form = new FormData();
    form.append('file', this.props.file);
    xhr.send(form);
  },
  render: function() {
    let bar = null;
    // This is a bit ugly, might want to make it its own component
    if (!this.state.complete) {
      bar = <div className='progress'>
              <div className='progress-bar' style={{width: this.state.percent + '%'}}>
                {this.state.percent + '%'}
              </div>
            </div>;
    } else {
      if (this.state.error) {
        bar = this.state.message;
      } else {
        bar = <a href={this.state.url} target='_BLANK'>{this.state.message}</a>;
      }
    }
    return (
      <tr>
        <td>
          {this.props.name}
        </td>
        <td>
          {bar}
        </td>
      </tr>
    );
  }
});
