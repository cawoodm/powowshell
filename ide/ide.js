/* global Vue dragula stepForm dataTableBuilder pipelineManager */

// Load modules depending on environment
if (typeof process !== 'undefined') {
  // Electron/Node environment
  var pow = require('./js/pow').pow;
  modComponentList = require("./js/component-list") //  eslint-disable-line
  modCmdletList = require("./js/cmdlet-list") //  eslint-disable-line
  pipelineManager = require("./js/pipeline-manager") //  eslint-disable-line
  pipelineForm = require("./js/pipeline-form") //  eslint-disable-line
  stepForm = require("./js/step-form") //  eslint-disable-line
  modLoading = require("./js/loading") //  eslint-disable-line
  const electron = require('electron');
  var { dialog } = electron.remote;
} else {
  // Browser/demo environment
  // Modules loaded in index.html via dynamic script tags
}
// eslint-disable-next-line no-undef
modComponentList(Vue), modCmdletList(Vue), modLoading(Vue);

// Initialisation
let app = {};
// eslint-disable-next-line no-undef
app.pipelineForm = pipelineForm(Vue);
app.stepForm = stepForm(Vue, pipelineManager);
pipelineManager.reset();
app.components = {};
app.cmdlets = {};

app.getComponent = (reference) => {
  if (!app.components || Object.keys(app.components).length === 0) throw new Error('Components not loaded!')
  let ref = reference.toLowerCase();
  let res = app.components.filter((item) => item.reference.toLowerCase() === ref);
  if (res.length === 0) {
    if (!app.cmdlets || Object.keys(app.cmdlets).length === 0) throw new Error('Cmdlets not loaded!')
    res = app.cmdlets.filter((item) => item.reference === ref);
  }
  if (!res || !res.length) return app.root.showErrorMessage(`Component/Cmdlet '${reference}' not found! Consider reloading the cache with 'pow cmdlets generate'.`)
  return res.length > 0 ? res[0] : null;
}
app.DEVMODE = true;
Vue.config.devtools = app.DEVMODE;
Vue.config.productionTip = false;

window.onload = function () {
  app.root = new Vue({
    el: '#root',
    data: {
      panels: [false, false, false],
      message: {
        show: false,
        message: '',
        color: 'primary',
        timeout: 3000
      },
      longMessage: {
        show: false,
        message: '',
        color: 'error'
      },
      codeEditor: {
        show: false,
        message: '',
        color: 'info'
      },
      pipeline: {},
      autosave: true
    },
    methods: {
      componentsUpdated: function () {
        let root = this;
        // Make .drag elements draggable
        const dragOpts = {
          revertOnSpill: true, // true=Go back if not dropped
          accepts: function (el, target) {
            return target.className.indexOf('drop') >= 0;
          }
        };
        app.dragula = dragula([].slice.call(document.querySelectorAll('.drag,.drop')), dragOpts).on('drop', function (el, space) {
          let id = el.getAttribute('d-id');
          let ref = el.getAttribute('d-ref');
          try {
            if (ref) {
              // This is a component
              let component = app.getComponent(ref);
              root.$refs.stepGrid.addComponent(space.id, component)
              root.showStepDialog(space.id);
            } else if (id) {
              // This is a step
              root.$refs.stepGrid.moveStep(id, space.id);
            }
          } catch(e) {
            this.showError('drag', e)
          }
          app.dragula.cancel(true)
        });
      },
      hideLoading: function () {
        this.showLoading(false);
      },
      showLoading: function (msg, title) {
        if (msg === 0)
          this.$refs.loading.close();
        else if (msg === false)
          this.$refs.loading.showLoading(false);
        else
          this.$refs.loading.showLoading(true, msg, title);
      },
      check: function () {
        let root = this;
        if (pipelineManager.isDirty())
          if (root.autosave || confirm('Do you want to save before checking?')) {
          return root.pipelineSave().then(root.check);
        }
        this.showLoading('Building ' + this.pipeline.id, 'Checking...')
        return pow.build('!' + this.pipeline.id)
          .then(() => {
            this.showLoading(false);
            this.showLoading('Verifying ' + this.pipeline.id, 'Checking...')
            return pow.verify('!' + this.pipeline.id);
          })
          .then((obj) => {
            if (obj.success) {
              this.showMessage('Validation OK', 'green')
            } else {
              this.handlePOWError(obj)
            }
          }).catch((err) => {
            this.handlePOWError(err)
          })
          .finally(this.hideLoading);
      },
      run: function () {
        let root = this;
        if (pipelineManager.isDirty() && confirm('Do you want to save before running?')) {
          return root.pipelineSave().then(root.run);
        }
        this.showLoading('Building ' + this.pipeline.id, 'Build and Run')
        return pow.build('!' + this.pipeline.id)
          // .then(()=>{
          //     this.showLoading(false);
          //     this.showLoading("Verifying "+this.pipeline.id, "Build and Run")
          //     return pow.verify("!"+this.pipeline.id);
          // })
          .then(() => {
            this.showLoading(false);
            this.showLoading('Running ' + this.pipeline.id, 'Build and Run')
            return pow.run('!' + this.pipeline.id)
          })
          .then((res) => {
            this.showMessages(res.messages);
            if (res.success && res.object) {
              dataTableBuilder.showTable(this.$root, { title: 'Result', items: res.object });
            } else {
              this.handlePOWError(res)
            }
          }).catch((err) => {
            this.handlePOWError(err)
          })
          .finally(this.hideLoading);
      },
      handlePOWError: function (err) {
        let message = '<pre>';
        console.log('handlePOWError', typeof err.message, typeof err.messages)
        if (err.constructor.name === 'POWError') message += 'POWError:\n';
        if (err.message) message += err.message + '\n' + err.stack;
        if (err.messages && Array.isArray(err.messages))
          message = err.messages.map(this.codeFormat).join('\n');
          /*err.messages.forEach(msg => {
            message += '\n' + msg.type + ': ' + (msg.obj ? '(' + msg.obj.scriptName + ') ' : '') + msg.message + ' ' + (msg.stack)
          });*/
        console.log(err);
        this.showLongMessage(message, 'error');
      },
      showMessages: function (messages, type) {
        if (!messages || !Array.isArray(messages) || !messages.length) return;
        let message = messages.map(this.codeFormat);
        this.showLongMessage(message.join('\n'), type, 'Messages');
      },
      codeFormat: function (msg) {
        let typeColors = { ERROR: 'red', WARNING: 'orange', INFO: 'green', VERBOSE: 'purple', ABORT: 'darkred' };
        let color = typeColors[msg.type] || 'black';
        return `<font face="consolas,courier new" color="${color}">` + msg.type + ': ' + (msg.obj ? '(' + msg.obj.scriptName + ') ' : '') + msg.message + '</font><br>'
      },
      showLongMessage: function (text, color, title) {
        console.log('showLongMessage', text)
        color = color || 'info';
        title = title || 'Error';
        if (this.longMessage.show) {
          // Already visible, add to the message
          this.longMessage.show = false;
          this.showLongMessage(this.longMessage.text + ' ' + text, color);
          return;
        }
        this.longMessage.title = title;
        this.longMessage.text = !text.match(/</) ? text : '';
        this.longMessage.html = text.match(/</) ? text : '';
        this.longMessage.color = color;
        this.longMessage.show = true;
      },
      showError: function (title, e) {
        this.showLongMessage(e.message + '\n' + e.stack, 'error', title);
      },
      showErrorMessage: function (msg) {
        return this.showMessage(msg, 'error')
      },
      showMessage: function (text, color) {
        console.log('showMessage', text, this.message)
        color = color || 'info';
        if (this.message.show) {
          // Already visible, add to the message
          this.message.show = false;
          this.showMessage(this.message.text + ' ' + text, color);
          return;
        }
        this.message.text = text;
        this.message.color = color;
        this.message.show = true;
      },
      showCodeEditor({code, title}) {
        this.codeEditor.title = title;
        this.codeEditor.text = code;
        this.codeEditor.show = true;
      },
      showStepDialog: function (id) {
        try {
          let step = pipelineManager.getStep(id);
          if (!step.reference) return;
          let component = app.getComponent(step.reference);
          app.stepForm.showForm(this.$root, step, component);
        } catch (e) {
          this.showLongMessage('<pre>' + e.message + '\n' + e.stack, 'error', 'IDE100:showStepDialog')
        }
      },
      componentsLoad: function (reload) {
        this.$refs.componentList.setLoading(true);
        return pow.components(null, reload)
          .then((obj) => {
            this.showLoading(false);
            app.components = obj.object;
            this.$refs.componentList.setComponents(app.components);
          })
          .catch(this.handlePOWError)
          .finally(() => this.$refs.componentList.setLoading(false));
      },
      cmdletsLoad: function () {
        this.$refs.cmdletList.setLoading(true);
        return pow.cmdlets()
          .then((obj) => {
            this.showLoading(false);
            this.showMessages(obj.messages);
            app.cmdlets = obj.object;
            this.$refs.cmdletList.setCmdlets(app.cmdlets);
          })
          .catch(this.handlePOWError)
          .finally(() => this.$refs.cmdletList.setLoading(false));
      },
      pipelineLoad: function (id) {
        // Load pipeline definition
        let root = this;
        if (pipelineManager.isDirty() && !confirm('Are you sure you want to clear the grid and load a new pipeline?')) return;
        this.showLoading(`Loading pipeline (${id})...`);
        return pow.pipeline(`${id}`)
          .then((res) => {
            pipelineManager.import(res.object);
            pow.execOptions.PSCore = res.object.runtime == 'ps5' ? 'powershell' : 'pwsh';
            if (root.$refs.stepGrid) root.$refs.stepGrid.doUpdate();
            this.pipeline = res.object;
            this.showLoading(false);
          })
          .catch(this.handlePOWError)
          .finally(() => this.showLoading(false));
      },
      pipelineEdit: function () {
        //this.$refs.pipelineForm.showForm(pipelineManager.getDefinition());
        app.pipelineForm.showForm(this.$root, pipelineManager.getDefinition());
      },
      pipelineFormOK: function (def) {
        Object.assign(this.pipeline, def);
      },
      pipelineNew: function () {
        if (pipelineManager.isDirty() && !confirm('Are you sure you want to clear the grid and start a new pipeline?')) return;
        pipelineManager.reset();
        this.pipeline = pipelineManager.getDefinition()
        app.pipelineForm.showForm(this.$root, pipelineManager.getDefinition());
        this.redraw();
      },
      pipelineOpen: function () {
        if (typeof dialog === 'undefined') return alert('Not implemented in the demo!\nTry download the app and run it with electron for all the features.')
        dialog.showOpenDialog({
          properties: ['openFile'],
          filters: { name: 'Pipelines', extensions: ['json'] }
        }).then(data => {
          const file = data.filePaths;
          if (!file || !file.length || !file[0]) return;
          pow.load(file[0]).then((res) => {
            pipelineManager.import(res.object);
            if (this.$refs.stepGrid) this.$refs.stepGrid.doUpdate();
            this.pipeline = pipelineManager.getDefinition();
          }).catch(this.handlePOWError);
        }).catch(this.handlePOWError);

      },
      pipelineBuild: function () {
        let root = this;
        if (pipelineManager.isDirty() && confirm('Do you want to save before building?')) {
          return root.pipelineSave().then(root.check);
        }
        this.showLoading('Building ' + this.pipeline.id, 'Building...')
        return pow.build('!' + this.pipeline.id)
          .then(() => {
            this.showLoading(false);
            this.showLoading('Verifying ' + this.pipeline.id, 'Building...')
            return pow.verify('!' + this.pipeline.id);
          })
          .then((obj) => {
            if (obj.success) {
              this.showMessage('Built and verified OK', 'green')
            } else {
              this.handlePOWError(obj)
            }
            this.showLoading(0);
          }).catch((err) => {
            this.showLoading(0);
            this.handlePOWError(err)
          });
      },
      pipelineSave: function () {
        let root = this;
        let pipeline = pipelineManager.export();
        // TODO: Use existing pipeline id or generate a new one
        let pipelineId = pipeline.id || ('pipeline' + Math.random().toString(36).substring(7));
        return pow.save(pipeline, pipelineId)
          .then(() => {
            pipelineManager.setClean();
            root.showMessage(`Saved ${pipelineId}`);
          })
          .catch(this.handlePOWError);
      },
      redraw: function () {
        // Must synch entire grid OR Vue.set(exactObject, newObject)
        this.$refs.stepGrid.doUpdate();
      }
    },
    mounted: function () {
      let root = this;
      // Listen for events
      this.$root.$on('stepSave', (newStep) => {
        pipelineManager.setStep(newStep);
        if(root.autosave)
          this.pipelineSave().then(this.redraw);
        else
          this.redraw();
      });
      this.$root.$on('pipelineFormOK', this.pipelineFormOK);
      this.$root.$on('cmdletsLoad', this.cmdletsLoad);
      this.$root.$on('componentsLoad', this.componentsLoad);
      this.$root.$on('componentHelp', (step, component) => {
        pow.exec(`Get-Help ${component.executable} -Full`).then(out => {
          this.showLongMessage(`<code>${out.output}</code>`, null, component.name);
        })
      });
      this.$root.$on('codeEditor', this.showCodeEditor);
      this.$root.$on('componentExamples', (reference, type) => {
        let ref = type === 'cmdlet' ? reference : '!' + reference;
        pow.examples(ref)
          .then((res) => {
            if (!res.object || res.object.length === 0) return alert('No examples found!')
            let examples = res.object.map((o) => {
              return '<h4>' + o.title + '</h4><pre>' + o.code.replace('`n', '\n') + '</pre>';
            });
            this.showLongMessage(examples.join('<hr>'), 'yellow darken-1', 'Examples')
          }).catch(this.handlePOWError);
      });
      this.$root.$on('stepPreview', (step) => {
        if (typeof step === 'string') { step = pipelineManager.getStep(step); }
        if (!step.reference) return this.showErrorMessage('Unknown step to preview: ' + step);
        return pow.build('!' + this.pipeline.id)
          .then(() => {
            try {
              let component = app.getComponent(step.reference);
              this.showLoading('Generating preview...')
              pow.preview('!' + this.pipeline.id, step, component).then((res) => {
                if (res.object)
                  dataTableBuilder.showTable(this.$root, { title: 'Result', items: res.object });
                else // TODO: Check preview of non-object output?
                  this.showLongMessage(res.output, null, 'Preview')
              }).catch(this.handlePOWError)
              .finally(this.hideLoading);
            } catch(e) {
              this.showError('stepPreview', e)
            }
          });
      });
      this.$root.$on('stepRemove', (step) => {
        if (typeof step === 'string') { step = pipelineManager.getStep(step); }
        if (confirm('Are you sure you want to remove this step?')) {
          pipelineManager.removeStep(step.id);
          this.redraw();
        }
      });
      pow.execOptions.PSCore = 'pwsh';
      if (app.DEVMODE) {
        //console.clear(); // Vue/electron junk warnings
        pow.execOptions.debug = true;
        //root.componentsLoad();root.cmdletsLoad();return;
        pow.init('!examples')
          //.then(() => root.pipelineLoad("pipeline1"))
          //.then(() => root.pipelineLoad("pipeline2"))
          //.then(() => root.pipelineLoad("pipeline3"))
          //.then(() => root.pipelineLoad('procmon1'))
          //.then(() => root.pipelineLoad('errortest'))
          //.then(() => root.pipelineLoad('code'))
          .then(() => root.pipelineLoad('elasticsearch'))
          //.then(() => root.pipelineLoad('dns'))
          //.then(() => root.pipelineLoad('cmdlets'))
          //.then(()=>root.check())
          //.then(() => root.run())
          .then(() => {
            //root.$emit('codeEditor', {title: 'foo', code: 'console.log("Hello, world!");'})
          })
          .then(() => {
            //console.clear();
            return Promise.all([root.componentsLoad(),root.cmdletsLoad()]);
            /*
            return root.componentsLoad()
            return root.componentsLoad().then(()=>{
              return root.cmdletsLoad()
            })
            */
          })
          .then(() => {
            //root.$emit('stepPreview', 'A1')
            root.showStepDialog('B1');
          })
          .catch(this.handlePOWError);
      } else {
        root.componentsLoad();
        root.cmdletsLoad();
      }
    }
  });
}