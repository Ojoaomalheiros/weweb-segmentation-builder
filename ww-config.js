export default {
  editor: {
    label: {
      en: 'Segmentation Builder',
      pt: 'Construtor de Segmentos',
    },
    icon: 'filter',
  },
  properties: {
    // Header Configuration
    title: {
      label: { en: 'Title', pt: 'Título' },
      type: 'Text',
      section: 'settings',
      defaultValue: 'Criar Segmento',
      bindable: true,
      /* wwEditor:start */
      bindingValidation: {
        type: 'string',
        tooltip: 'Title of the segmentation builder',
      },
      propertyHelp: 'Main title displayed at the top of the builder',
      /* wwEditor:end */
    },

    description: {
      label: { en: 'Description', pt: 'Descrição' },
      type: 'LongText',
      section: 'settings',
      defaultValue: '',
      bindable: true,
      /* wwEditor:start */
      bindingValidation: {
        type: 'string',
        tooltip: 'Optional description text',
      },
      propertyHelp: 'Optional description shown below the title',
      /* wwEditor:end */
    },

    // Required Data
    empresaId: {
      label: { en: 'Company ID', pt: 'ID da Empresa' },
      type: 'Number',
      section: 'settings',
      bindable: true,
      /* wwEditor:start */
      bindingValidation: {
        type: 'number',
        tooltip: 'Required: Company ID for the segment',
      },
      propertyHelp: 'REQUIRED: The ID of the company creating the segment',
      /* wwEditor:end */
    },

    // Features
    showPreview: {
      label: { en: 'Show Preview', pt: 'Mostrar Preview' },
      type: 'OnOff',
      section: 'settings',
      defaultValue: true,
      bindable: true,
      /* wwEditor:start */
      bindingValidation: {
        type: 'boolean',
        tooltip: 'Show/hide the preview section',
      },
      propertyHelp: 'Enable preview to show estimated customer count before saving',
      /* wwEditor:end */
    },

    // Styling
    primaryColor: {
      label: { en: 'Primary Color', pt: 'Cor Primária' },
      type: 'Color',
      section: 'style',
      defaultValue: '#007aff',
      bindable: true,
      /* wwEditor:start */
      bindingValidation: {
        type: 'string',
        tooltip: 'Main color used for buttons and highlights',
      },
      /* wwEditor:end */
    },

    backgroundColor: {
      label: { en: 'Background Color', pt: 'Cor de Fundo' },
      type: 'Color',
      section: 'style',
      defaultValue: '#ffffff',
      bindable: true,
      /* wwEditor:start */
      bindingValidation: {
        type: 'string',
        tooltip: 'Background color of the builder',
      },
      /* wwEditor:end */
    },

    borderColor: {
      label: { en: 'Border Color', pt: 'Cor da Borda' },
      type: 'Color',
      section: 'style',
      defaultValue: '#e0e0e0',
      bindable: true,
      /* wwEditor:start */
      bindingValidation: {
        type: 'string',
        tooltip: 'Color used for borders and dividers',
      },
      /* wwEditor:end */
    },
  },
  triggerEvents: [
    {
      name: 'save-segment',
      label: { en: 'On save segment', pt: 'Ao salvar segmento' },
      event: {
        payload: {},
      },
      default: true,
    },
    {
      name: 'cancel',
      label: { en: 'On cancel', pt: 'Ao cancelar' },
      event: {},
    },
  ],
};
