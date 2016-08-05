## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

<%!
  from desktop import conf
  from desktop.views import commonheader, commonfooter, commonshare, commonimportexport
  from django.utils.translation import ugettext as _
%>

<%namespace name="actionbar" file="actionbar.mako" />
<%namespace name="assist" file="/assist.mako" />
<%namespace name="tableStats" file="/table_stats.mako" />
<%namespace name="require" file="/require.mako" />

${ commonheader(_("Solr Indexes"), "search", user, "60px") | n,unicode }

${ require.config() }

${ tableStats.tableStats() }
${ assist.assistPanel() }

<link rel="stylesheet" href="${ static('notebook/css/notebook.css') }">
<link rel="stylesheet" href="${ static('desktop/css/wizard.css') }">
<style type="text/css">
% if conf.CUSTOM.BANNER_TOP_HTML.get():
  .show-assist {
    top: 110px!important;
  }
  .main-content {
    top: 112px!important;
  }
% endif
  .path {
    margin-bottom: 0!important;
    border-right: none!important;
  }
</style>

<div class="navbar navbar-inverse navbar-fixed-top">
  <div class="navbar-inner">
    <div class="container-fluid">
      <div class="nav-collapse">
        <ul class="nav">
          <li class="currentApp">
            <a href="/indexer/indexer">
              <i class="fa fa-database app-icon"></i> ${_('Indexes')}</a>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>
</div>

<a title="${_('Toggle Assist')}" class="pointer show-assist" data-bind="visible: !$root.isLeftPanelVisible() && $root.assistAvailable(), click: function() { $root.isLeftPanelVisible(true); }">
  <i class="fa fa-chevron-right"></i>
</a>


<div class="main-content">
  <div class="vertical-full container-fluid" data-bind="style: { 'padding-left' : $root.isLeftPanelVisible() ? '0' : '20px' }">
    <div class="vertical-full">
      <div class="vertical-full row-fluid panel-container">

        <div class="assist-container left-panel" data-bind="visible: $root.isLeftPanelVisible() && $root.assistAvailable()">
          <a title="${_('Toggle Assist')}" class="pointer hide-assist" data-bind="click: function() { $root.isLeftPanelVisible(false) }">
            <i class="fa fa-chevron-left"></i>
          </a>
          <div class="assist" data-bind="component: {
              name: 'assist-panel',
              params: {
                user: '${user.username}',
                sql: {
                  sourceTypes: [{
                    name: 'hive',
                    type: 'hive'
                  }],
                  navigationSettings: {
                    openItem: false,
                    showStats: true
                  }
                },
                visibleAssistPanels: ['sql']
              }
            }"></div>
        </div>
        <div class="resizer" data-bind="visible: $root.isLeftPanelVisible() && $root.assistAvailable(), splitDraggable : { appName: 'notebook', leftPanelVisible: $root.isLeftPanelVisible }"><div class="resize-bar">&nbsp;</div></div>

        <div class="right-panel">
          <div style="margin: 10px">
          <!-- ko template: 'create-index-wizard' --><!-- /ko -->
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<div id="chooseFile" class="modal hide fade">
  <div class="modal-header">
    <a href="#" class="close" data-dismiss="modal">&times;</a>
    <h3>${_('Choose a file')}</h3>
  </div>
  <div class="modal-body">
    <div id="filechooser"></div>
  </div>
  <div class="modal-footer"></div>
</div>

<script type="text/html" id="create-index-wizard">
  <div data-bind="visible: createWizard.show">

    <ol class="list-inline text-center step-indicator">
      <li data-bind="css: { 'active': currentStep() == 1, 'complete': currentStep() > 1 }">
        <div class="step">
          <!-- ko if: currentStep() == 1 -->
            <!-- ko if: createWizard.isGuessingFormat -->
              <span class="fa fa-spinner fa-spin"></span>
            <!-- /ko -->
            <!-- ko ifnot: createWizard.isGuessingFormat -->
              1
            <!-- /ko -->
          <!-- /ko -->
          <!-- ko ifnot: currentStep() == 1 -->
          <span class="fa fa-check"></span>
          <!-- /ko -->
        </div>
        <div class="caption">${ _('Pick it') }</div>
      </li>
      <li data-bind="css: { 'inactive': currentStep() == 1, 'active': currentStep() == 2, 'complete': currentStep() == 3 }">
        <div class="step">
          <!-- ko if: currentStep() < 3 -->
            <!-- ko if: createWizard.isGuessingFieldTypes -->
              <span class="fa fa-spinner fa-spin"></span>
            <!-- /ko -->
            <!-- ko ifnot: createWizard.isGuessingFieldTypes -->
              2
            <!-- /ko -->
          <!-- /ko -->
          <!-- ko if: currentStep() == 3 -->
          <span class="fa fa-check"></span>
          <!-- /ko -->
        </div>
        <div class="caption">${ _('Tweak it') }</div>
      </li>
      <li data-bind="css: { 'inactive': currentStep() < 3, 'active': currentStep() == 3 }">
        <div class="step">
          <!-- ko if: createWizard.isIndexing -->
            <span class="fa fa-spinner fa-spin"></span>
          <!-- /ko -->
          <!-- ko ifnot: createWizard.isIndexing -->
            3
          <!-- /ko -->
        </div>
        <div class="caption">${ _('Index it') }</div>
      </li>
    </ol>

    <!-- ko if: currentStep() == 1 -->
    <div class="control-group" data-bind="css: { error: createWizard.isNameAvailable() === false && createWizard.fileFormat().name().length == 0, success: createWizard.isNameAvailable()}">
      <label for="collectionName" class="control-label">${ _('Name') }</label>
      <div class="controls">
        <input type="text" class="form-control" id = "collectionName" data-bind="value: createWizard.fileFormat().name, valueUpdate: 'afterkeydown'">
        <span class="help-block" data-bind="visible: createWizard.isNameAvailable() === true">${ _('Creating a new collection') }</span>
        <span class="help-block" data-bind="visible: createWizard.isNameAvailable() === false && createWizard.fileFormat().name().length > 0">${_('Adding data to this existing collection') }</span>
        <span class="help-block" data-bind="visible: createWizard.isNameAvailable() === false && createWizard.fileFormat().name().length == 0">${_('This collection needs a name') }</span>
      </div>
    </div>

    <div class="control-group" data-bind="visible: createWizard.fileFormat().name().length > 0">
      <select data-bind="options: createWizard.fileFormat().inputFormats, value: createWizard.fileFormat().inputFormat"></select>

      <div data-bind="visible: createWizard.fileFormat().inputFormat() == 'file'">
        <label for="path" class="control-label">${ _('Path') }</label>
        <div class="controls">
          <input type="text" class="form-control path" data-bind="filechooser: createWizard.fileFormat().path, filechooserOptions: { skipInitialPathIfEmpty: true }">
          <a href="javascript:void(0)" class="btn" data-bind="click: createWizard.guessFormat">${_('Guess Format')}</a>
        </div>
      </div>

      <div data-bind="visible: createWizard.fileFormat().inputFormat() == 'table'">
        <label for="path" class="control-label">${ _('Table') }</label>
        <div class="controls">
          <input type="text" data-bind="value: createWizard.fileFormat().table">
          <a href="javascript:void(0)" class="btn" data-bind="click: createWizard.guessFormat">${_('Select')}</a>
        </div>
      </div>

      <div data-bind="visible: createWizard.fileFormat().inputFormat() == 'query'">
        <label for="path" class="control-label">${ _('Query') }</label>
        <div class="controls">
          <select data-bind="options: createWizard.fileFormat().queries, value: createWizard.fileFormat().query, optionsText: 'name'"></select>
          <a href="javascript:void(0)" class="btn" data-bind="click: createWizard.guessFormat">${_('Select')}</a>
        </div>
      </div>
    </div>


    <div data-bind="visible: createWizard.fileFormat().show">
      <h3>
        ${_('File Type')}: <select data-bind="options: $root.createWizard.fileTypes, optionsText: 'description', value: $root.createWizard.fileType"></select>
      </h3>
      <div data-bind="with: createWizard.fileFormat().format">
        <!-- ko template: {name: 'format-settings'}--><!-- /ko -->
      </div>
    </div>
    <!-- /ko -->


        <!-- ko if: createWizard.fileFormat().format() && createWizard.fileFormat().format().isCustomizable() -->
          <!-- ko if: currentStep() == 2 -->
          <h3>${_('Fields')}</h3>
          <!-- ko if: createWizard.isGuessingFieldTypes -->
            <i class="fa fa-spinner fa-spin"></i>
          <!-- /ko -->
          <div data-bind="foreach: createWizard.fileFormat().columns">
            <div data-bind="template: { name:'field-template',data:$data}"></div>
          </div>
          <!-- /ko -->

          <!-- ko if: currentStep() == 3 -->
          <h3>${_('Preview')}</h3>
          <!-- ko if: createWizard.isGuessingFieldTypes -->
            <i class="fa fa-spinner fa-spin"></i>
          <!-- /ko -->
          <div style="overflow: auto">
            <table style="margin:auto;text-align:left">
              <thead>
                <tr data-bind="foreach: createWizard.fileFormat().columns">
                  <!-- ko template: 'field-preview-header-template' --><!-- /ko -->
                </tr>
              </thead>
              <tbody data-bind="foreach: createWizard.sample">
                <tr data-bind="foreach: $data">
                  <!-- ko if: $index() < $root.createWizard.fileFormat().columns().length -->
                    <td data-bind="visible: $root.createWizard.fileFormat().columns()[$index()].keep, text: $data">
                    </td>

                    <!-- ko with: $root.createWizard.fileFormat().columns()[$index()] -->
                      <!-- ko template: 'output-generated-field-data-template' --> <!-- /ko -->
                    <!-- /ko -->
                  <!-- /ko -->
                </tr>
              </tbody>
            </table>
          </div>
          <!-- /ko -->
        <!-- /ko -->


      <!-- ko if: previousStepVisible -->
        <a class="btn" data-bind="click: previousStep">${ _('Previous') }</a>
      <!-- /ko -->

      <!-- ko if: nextStepVisible -->
        <a class="btn" data-bind="click: nextStep">${ _('Next') }</a>
      <!-- /ko -->

      <!-- ko if: currentStep() == 3 -->
        <a href="javascript:void(0)" class="btn" data-bind="visible: !createWizard.indexingStarted() , click: createWizard.indexFile, css: {disabled : !createWizard.readyToIndex()}">${_('Index File!')}</a>
      <!-- /ko -->

        <h4 class="error" data-bind="visible: !createWizard.isNameAvailable() && createWizard.fileFormat().name().length > 0">${_('Will try to add to existing collection')}</h4>
        <h4 class="error" data-bind="visible: !createWizard.isNameAvailable() && createWizard.fileFormat().name().length == 0">${_('Collection needs a name')}</h4>


        <a href="javascript:void(0)" class="btn btn-success" data-bind="visible: createWizard.jobId, attr: {href: '/oozie/list_oozie_workflow/' + createWizard.jobId() }" target="_blank" title="${ _('Open') }">
          ${_('View Indexing Status')}
        </a>


  </div>
</script>

<script type="text/html" id="format-settings">
  <!-- ko foreach: {data: getArguments(), as: 'argument'} -->
    <h4 data-bind="text: argument.description"></h4>
    <!-- ko template: {name: 'arg-'+argument.type, data:{description: argument.description, value: $parent[argument.name]}}--><!-- /ko -->
  <!-- /ko -->
</script>

<script type="text/html" id="field-template">
  <div>
    <span>${_('Unique')}</span><input type="checkbox" data-bind="checked: unique">
    <span>${_('Keep')}</span><input type="checkbox" data-bind="checked: keep">
    <span>${_('Required')}</span><input type="checkbox" data-bind="checked: required">
    <input type="text" data-bind="value: name"></input> - <select data-bind="options: $root.createWizard.fieldTypes, value: type"></select>
    <button class="btn" data-bind="click: $root.createWizard.addOperation">${_('Add Operation')}</button>
  </div>
  <div data-bind="foreach: operations">
    <div data-bind="template: { name:'operation-template',data:{operation: $data, list: $parent.operations}}"></div>
  </div>
</script>

<script type="text/html" id="operation-template">
  <div><select data-bind="options: $root.createWizard.operationTypes.map(function(o){return o.name});, value: operation.type"></select>
  <!-- ko template: "args-template" --><!-- /ko -->
    <!-- ko if: operation.settings().outputType() == "custom_fields" -->
      <input type="number" data-bind="value: operation.numExpectedFields">
    <!-- /ko -->
    <button class="btn" data-bind="click: function(){$root.createWizard.removeOperation(operation, list)}">${_('remove')}</button>
    <div style="padding-left:50px" data-bind="foreach: operation.fields">
      <div data-bind="template: { name:'field-template',data:$data}"></div>
    </div>

  </div>
</script>

<script type="text/html" id="field-preview-header-template">

  <th data-bind="visible: keep, text: name" style="padding-right:60px"></th>
  <!-- ko foreach: operations -->
    <!--ko foreach: fields -->
      <!-- ko template: 'field-preview-header-template' --><!-- /ko -->
    <!-- /ko -->
  <!--/ko -->
</script>


<script type="text/html" id="output-generated-field-data-template">
  <!-- ko foreach: operations -->
    <!--ko foreach: fields -->
      <td data-bind="visible: keep">[[${_('generated')}]]</td>
      <!-- ko template: 'output-generated-field-data-template' --><!-- /ko -->
    <!-- /ko -->
  <!--/ko -->
</script>

<script type="text/html" id="args-template">
  <!-- ko foreach: {data: operation.settings().getArguments(), as: 'argument'} -->
    <h4 data-bind="text: description"></h4>
    <!-- ko template: {name: 'arg-'+argument.type, data:{description: argument.description, value: $parent.operation.settings()[argument.name]}}--><!-- /ko -->
  <!-- /ko -->

</script>

<script type="text/html" id="arg-text">
  <input type="text" data-bind="attr: {placeholder: description}, value: value">
</script>

<script type="text/html" id="arg-checkbox">
  <input type="checkbox" data-bind="checked: value">
</script>

<script type="text/html" id="arg-mapping">
  <!-- ko foreach: value-->
    <div>
      <input type="text" data-bind="value: key, attr: {placeholder: 'key'}">
      <input type="text" data-bind="value: value, attr: {placeholder: 'value'}">
      <button class="btn" data-bind="click: function(){$parent.value.remove($data)}">${_('Remove Pair')}</button>
    </div>
  <!-- /ko -->
  <button class="btn" data-bind="click: function(){value.push({key: ko.observable(''), value: ko.observable('')})}">${_('Add Pair')}</button>
  <br>
</script>

<script type="text/javascript" charset="utf-8">

  require([
    "knockout",
    "ko.charts",
    "desktop/js/apiHelper",
    "notebook/js/notebook.ko",
    "assistPanel",
    "tableStats",
    "knockout-mapping",
    "knockout-sortable",
    "ko.editable",
    "ko.hue-bindings"
  ], function (ko, charts, ApiHelper, EditorViewModel) {

    ko.options.deferUpdates = true;

    var fieldNum = 0;

    var getNewFieldName = function () {
      fieldNum++;
      return "new_field_" + fieldNum
    }

    var createDefaultField = function () {
      var defaultField = ${default_field_type | n};

      defaultField.name = getNewFieldName();

      return defaultField;
    };

    var Operation = function (type) {
      var self = this;

      var createArgumentValue = function (arg) {
        if (arg.type == "mapping") {
          return ko.observableArray([]);
        }
        else if (arg.type == "checkbox") {
          return ko.observable(false);
        }
        else {
          return ko.observable("");
        }
      }

      var constructSettings = function (type) {
        var settings = {};

        var operation = viewModel.createWizard.operationTypes.find(function (currOperation) {
          return currOperation.name == type;
        });

        for (var i = 0; i < operation.args.length; i++) {
          var argVal = createArgumentValue(operation.args[i]);

          if (operation.args[i].type == "checkbox" && operation.outputType == "checkbox_fields") {
            argVal.subscribe(function (newVal) {
              if (newVal) {
                self.fields.push(createDefaultField());
              }
              else {
                self.fields.pop();
              }
            });
          }

          settings[operation.args[i].name] = argVal;
        }

        settings.getArguments = function () {
          return operation.args
        };

        settings.outputType = function () {
          return operation.outputType;
        }

        return settings;
      };

      var init = function () {
        self.fields([]);
        self.numExpectedFields(0);

        self.numExpectedFields.subscribe(function (numExpectedFields) {
          if (numExpectedFields < self.fields().length) {
            self.fields(self.fields().slice(0, numExpectedFields));
          }
          else if (numExpectedFields > self.fields().length) {
            var difference = numExpectedFields - self.fields().length;

            for (var i = 0; i < difference; i++) {
              self.fields.push(createDefaultField());
            }
          }
        });

        self.settings(constructSettings(self.type()));
      }

      self.load = function (data) {
        self.numExpectedFields(data.numExpectedFields);

        var newSettings = constructSettings(data.type);
        for (var key in data.settings) {
          newSettings[key] = ko.mapping.fromJS(data.settings[key]);
        }
        self.settings(newSettings);

        data.fields.forEach(function (field) {
          self.fields.push(loadField(field));
        });
      }

      self.type = ko.observable(type);
      self.fields = ko.observableArray();
      self.numExpectedFields = ko.observable();
      self.settings = ko.observable();

      init();

      self.type.subscribe(function (newType) {
        init();
      });
    }

    var FileType = function (typeName, args) {
      var self = this;
      var type;

      var init = function () {
        self.type = ko.observable(typeName);

        var types = viewModel.createWizard.fileTypes

        for (var i = 0; i < types.length; i++) {
          if (types[i].name == typeName) {
            type = types[i];
            break;
          }
        }

        for (var i = 0; i < type.args.length; i++) {
          self[type.args[i].name] = ko.observable();
        }

        if (args) loadFromObj(args);

        for (var i = 0; i < type.args.length; i++) {
          self[type.args[i].name].subscribe(viewModel.createWizard.guessFieldTypes);
        }
      }

      var loadFromObj = function (args) {
        for (var attr in args) {
          self[attr] = ko.mapping.fromJS(args[attr]);
        }
      }

      self.getArguments = function () {
        return type.args;
      }

      self.isCustomizable = function () {
        return type.isCustomizable;
      }

      init();
    }

    var IndexerFormat = function (vm) {
      var self = this;

      self.name = ko.observable('');

      self.inputFormat = ko.observable('file');
      self.inputFormat.subscribe(function(val) {
        if (val == 'query') {
          self.getDocuments();
        }
      });
      self.inputFormats = ko.observableArray(['file', 'table', 'query']);

      // File
      self.path = ko.observable('');

      // Table
      self.table = ko.observable('');

      // Queries
      self.query = ko.observable('');
      self.queries = ko.observableArray([]);
      self.getDocuments = function() {
        $.get('/desktop/api2/docs/', {
          type: 'query-hive',
          include_trashed: false,
          sort: '-last_modified',
          limit: 100
        }, function(data) {
          if (data && data.documents) {
            var queries = [];
            $.each(data.documents, function(index, query) {
              queries.push(ko.mapping.fromJS(query));
            });
            self.queries(queries);
          }
        });
      };

      self.format = ko.observable();
      self.columns = ko.observableArray();

      self.show = ko.computed(function() {
        if (self.inputFormat() == 'file') {
          return self.path().length > 0 && self.columns().length > 0;
        } else if (self.inputFormat() == 'table') {
          return self.table().length > 0;
        } else if (self.inputFormat() == 'query') {
          return self.query().length > 0;
        }
      });
    };

    var CreateWizard = function (vm) {
      var self = this;
      var guessFieldTypesXhr;

      self.fileType = ko.observable();
      self.fileType.subscribe(function (newType) {
        if (self.fileFormat().format()) self.fileFormat().format().type(newType.name);
      });

      self.operationTypes = ${operators_json | n};

      self.fieldTypes = ${fields_json | n};
      self.fileTypes = ${file_types_json | n};


      self.show = ko.observable(true);
      self.showCreate = ko.observable(false);

      self.fileFormat = ko.observable(new IndexerFormat(vm));
      self.sample = ko.observableArray();

      self.jobId = ko.observable(null);

      self.indexingStarted = ko.observable(false);

      self.isNameAvailable = ko.computed(function () {
        var name = self.fileFormat().name();
        return viewModel && viewModel.collectionNameAvailable(name) && name.length > 0;
      });

      self.readyToIndex = ko.computed(function () {
        var validFields = self.fileFormat().columns().length;

        return self.fileFormat().name().length > 0 && validFields;
      });

      self.fileFormat().format.subscribe(function () {
        for (var i = 0; i < self.fileTypes.length; i++) {
          if (self.fileTypes[i].name == self.fileFormat().format().type()) {
            self.fileType(self.fileTypes[i]);
            break;
          }
        }

        if (self.fileFormat().format().type) {
          self.fileFormat().format().type.subscribe(function (newType) {
            self.fileFormat().format(new FileType(newType));
            self.fileFormat().columns.removeAll();
            self.guessFieldTypes();
          });
        }
      });

      self.isGuessingFormat = ko.observable(false);
      self.guessFormat = function () {
        self.isGuessingFormat(true);
        $.post("${ url('indexer:guess_format') }", {
          "fileFormat": ko.mapping.toJSON(self.fileFormat)
        }, function (resp) {
          var newFormat = ko.mapping.fromJS(new FileType(resp['type'], resp));
          self.fileFormat().format(newFormat);
          self.guessFieldTypes();

          self.isGuessingFormat(false);
          viewModel.wizardEnabled(true);
        }).fail(function (xhr, textStatus, errorThrown) {
          $(document).trigger("error", xhr.responseText);
          viewModel.isLoading(false);
        });
      };

      self.isGuessingFieldTypes = ko.observable(false);
      self.guessFieldTypes = function () {
        if (guessFieldTypesXhr) {
          guessFieldTypesXhr.abort();
        }
        self.isGuessingFieldTypes(true);
        guessFieldTypesXhr = $.post("${ url('indexer:guess_field_types') }", {
          "fileFormat": ko.mapping.toJSON(self.fileFormat)
        }, function (resp) {
          resp.columns.forEach(function (entry, i, arr) {
            arr[i] = ko.mapping.fromJS(entry);
          });
          self.fileFormat().columns(resp.columns);
          self.isGuessingFieldTypes(false);
          self.sample(resp.sample);
        }).fail(function (xhr, textStatus, errorThrown) {
          $(document).trigger("error", xhr.responseText);
          self.isGuessingFieldTypes(false);
          viewModel.isLoading(false);
        });
      };

      self.isIndexing = ko.observable(false);
      self.indexFile = function () {
        if (!self.readyToIndex()) return;

        self.indexingStarted(true);

        viewModel.isLoading(true);

        self.isIndexing(true);

        $.post("${ url('indexer:index_file') }", {
          "fileFormat": ko.mapping.toJSON(self.fileFormat)
        }, function (resp) {
          self.showCreate(true);
          self.jobId(resp.jobId);
          viewModel.isLoading(false);
        }).fail(function (xhr, textStatus, errorThrown) {
          $(document).trigger("error", xhr.responseText);
          viewModel.isLoading(false);
        });
      }

      self.removeOperation = function (operation, operationList) {
        operationList.remove(operation);
      }

      self.addOperation = function (field) {
        field.operations.push(new Operation("split"));
      }

      self.load = function (state) {
        self.fileFormat().name(state.name);
        self.fileFormat().show(state.show);
        self.fileFormat().path(state.path);
        self.fileFormat().columns.removeAll();
        if (state.format && 'type' in state.format) {
          koFormat = ko.mapping.fromJS(new FileType(state.format.type, state.format));
          self.fileFormat().format(koFormat);
        }
        if (state.columns) state.columns.forEach(function (currCol) {
          self.fileFormat().columns.push(loadField(currCol));
        });
      }
    };

    var loadField = function (currField) {
      var koField = ko.mapping.fromJS(currField);

      koField.operations.removeAll();

      currField.operations.forEach(function (operationData) {
        var operation = new Operation(operationData.type);
        operation.load(operationData);

        koField.operations.push(operation);
      });

      return koField;
    }

    var IndexerViewModel = function (options) {
      var self = this;

      self.apiHelper = ApiHelper.getInstance(options);
      self.assistAvailable = ko.observable(true);
      self.isLeftPanelVisible = ko.observable();
      self.apiHelper.withTotalStorage('assist', 'assist_panel_visible', self.isLeftPanelVisible, true);

      // wizard related
      self.wizardEnabled = ko.observable(false);
      self.currentStep = ko.observable(1);
      self.previousStepVisible = ko.pureComputed(function(){
        return self.currentStep() > 1;
      });
      self.nextStepVisible = ko.pureComputed(function(){
        return self.currentStep() < 3 && self.wizardEnabled();
      });
      self.nextStep = function () {
        if (self.nextStepVisible()){
          self.currentStep(self.currentStep()+1);
        }
      }
      self.previousStep = function () {
        if (self.previousStepVisible()){
          self.currentStep(self.currentStep()-1);
        }
      }

      self.collections = ${ indexes_json | n }.
      filter(function (index) {
        return index.type == 'collection';
      });

      self.createWizard = new CreateWizard(self);
      self.isLoading = ko.observable(false);

      self.collectionNameAvailable = function (name) {
        var matchingCollections = self.collections.filter(function (collection) {
          return collection.name == name;
        });

        return matchingCollections.length == 0;
      }
    };

    var viewModel;

    $(document).ready(function () {
      var options = {
        user: '${ user.username }',
        i18n: {
          errorLoadingDatabases: "${ _('There was a problem loading the databases') }",
          errorLoadingTablePreview: "${ _('There was a problem loading the table preview.') }"
        }
      }
      viewModel = new IndexerViewModel(options);
      ko.applyBindings(viewModel);
    });
  });
</script>

${ commonfooter(request, messages) | n,unicode }