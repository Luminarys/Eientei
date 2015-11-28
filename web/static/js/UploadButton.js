export default React.createClass({
  getInitialState: function() {
    return {message: 'Select or drop file(s)'};
  },
  stopEvent: function(event) {
    event.stopPropagation();
    event.preventDefault();
  },
  handleClick: function(event) {
    this.stopEvent(event);
    document.getElementById('browse').click();
  },
  handleDragEnter: function(event) {
    this.stopEvent(event);
    this.setState({message: 'Drop it here!'});
  },
  handleDragLeave: function(event) {
    this.stopEvent(event);
    this.setState({message: 'Select or drop file(s)!'});
  },
  handleDrop: function(event) {
    this.stopEvent(event);
    this.props.onDrop(event);
  },
  handleDragOver: function(event) {
    this.stopEvent(event);
  },
  render: function() {
    return (
      <div onClick={this.handleClick}
        onDrop={this.handleDrop}
        onDragOver={this.handleDragOver}
        onDragEnter={this.handleDragEnter}
        onDragLeave={this.handleDragLeave}
        className='target'>
        {this.state.message}
      </div>
    );
  }
});
