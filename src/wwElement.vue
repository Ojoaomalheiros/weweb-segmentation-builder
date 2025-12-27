<template>
  <div class="segmentation-page">
    <!-- Top Header -->
    <div class="page-header">
      <h1 class="page-title">{{ pageTitle }}</h1>
      <div class="header-actions">
        <div v-if="showValidation && !canSave" class="validation-message">
          <span v-if="!empresaId">⚠️ Empresa não encontrada - vincule a collection "user" no painel de configurações</span>
          <span v-else>Por favor, preencha todos os campos obrigatórios</span>
        </div>
        <button @click="handleCancel" class="btn-secondary" type="button">
          Cancelar
        </button>
        <button
          @click="handleSave"
          :disabled="!canSave || isSaving"
          class="btn-primary"
          :class="{ 'is-loading': isSaving }"
          type="button"
        >
          <span v-if="isSaving" class="loading-content">
            <svg class="spinner" viewBox="0 0 24 24">
              <circle class="spinner-circle" cx="12" cy="12" r="10" fill="none" stroke-width="3"></circle>
            </svg>
            Criando segmento...
          </span>
          <span v-else>Salvar segmento</span>
        </button>
      </div>
    </div>

    <!-- Content Area -->
    <div class="page-content">
      <!-- Section Header -->
      <div class="section-card">
        <h2 class="section-title">Construtor de segmento</h2>
        <p class="section-description">
          Os segmentos permitem rastrear e analisar clientes que atendem a certos critérios
        </p>

        <!-- Name and Description Row -->
        <div class="fields-row">
          <div class="field-group">
            <label class="field-label">Nome *</label>
            <input
              v-model="segmentName"
              type="text"
              class="field-input"
              :class="{ 'has-error': showValidation && !segmentName.trim() }"
              placeholder="Digite o nome do segmento"
              @input="handleSegmentNameChange"
            />
          </div>

          <div class="field-group">
            <label class="field-label">Descrição</label>
            <input
              v-model="segmentDescription"
              type="text"
              class="field-input"
              placeholder="Digite a descrição do segmento"
              @input="handleSegmentDescriptionChange"
            />
          </div>
        </div>

        <!-- Builder Title -->
        <h3 class="builder-title">Criar um segmento para clientes que:</h3>

        <!-- Groups and Conditions -->
        <div class="conditions-area">
          <template v-for="(group, groupIndex) in groups" :key="group.groupNumber">
            <!-- Group Box -->
            <div class="group-box">
              <!-- Conditions in this group -->
              <template
                v-for="(condition, condIndex) in group.conditions"
                :key="`${group.groupNumber}-${condIndex}`"
              >
                <!-- OU Label (separate row) -->
                <div v-if="condIndex > 0" class="label-ou">OU</div>

                <!-- Condition Row -->
                <div class="condition-row">
                  <!-- Condition Content -->
                  <div class="condition-content">
                  <!-- Field Selector -->
                  <select
                    v-model="condition.field"
                    @change="handleFieldChange(groupIndex, condIndex)"
                    class="select-field"
                    :class="{ 'has-error': hasFieldError(condition, 'field') }"
                  >
                    <option value="">Selecione o Critério</option>
                    <optgroup
                      v-for="category in fieldCategories"
                      :key="category.label"
                      :label="category.label"
                    >
                      <option
                        v-for="field in category.fields"
                        :key="field.value"
                        :value="field.value"
                      >
                        {{ field.label }}
                      </option>
                    </optgroup>
                  </select>

                  <!-- Operator -->
                  <select
                    v-if="condition.field"
                    v-model="condition.operator"
                    @change="handleOperatorChange(groupIndex, condIndex)"
                    class="select-field"
                    :class="{ 'has-error': hasFieldError(condition, 'operator') }"
                  >
                    <option value="">Selecione</option>
                    <option
                      v-for="op in getOperatorsForField(condition.field)"
                      :key="op.value"
                      :value="op.value"
                    >
                      {{ op.label }}
                    </option>
                  </select>

                  <!-- Value Inputs -->
                  <template v-if="condition.operator">
                    <!-- Numeric between -->
                    <template v-if="getFieldType(condition.field) === 'numeric' && condition.operator === 'between'">
                      <input
                        v-model.number="condition.valueMin"
                        type="number"
                        min="0"
                        class="input-small"
                        :class="{ 'has-error': hasFieldError(condition, 'valueMin') }"
                        placeholder="Mín"
                      />
                      <input
                        v-model.number="condition.valueMax"
                        type="number"
                        min="0"
                        class="input-small"
                        :class="{ 'has-error': hasFieldError(condition, 'valueMax') }"
                        placeholder="Máx"
                      />
                    </template>

                    <!-- Numeric single -->
                    <input
                      v-else-if="getFieldType(condition.field) === 'numeric'"
                      v-model.number="condition.valueMin"
                      type="number"
                      min="0"
                      class="input-small"
                      :class="{ 'has-error': hasFieldError(condition, 'valueMin') }"
                      placeholder="30"
                    />

                    <!-- Gender (special case) -->
                    <select
                      v-else-if="condition.field === 'gender'"
                      v-model="condition.valueText"
                      class="select-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                    >
                      <option value="">Selecione</option>
                      <option value="masculino">Masculino</option>
                      <option value="feminino">Feminino</option>
                      <option value="outro">Outro</option>
                    </select>

                    <!-- Cashback Status (special case) -->
                    <select
                      v-else-if="condition.field === 'cashback_last_status'"
                      v-model="condition.valueText"
                      class="select-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                    >
                      <option value="">Selecione</option>
                      <option value="criado">Criado</option>
                      <option value="ativo">Ativo</option>
                      <option value="utilizado">Utilizado</option>
                      <option value="vencido">Vencido</option>
                      <option value="cancelado">Cancelado</option>
                    </select>

                    <!-- RFM Segment (special case) -->
                    <select
                      v-else-if="condition.field === 'rfm_segment'"
                      v-model="condition.valueText"
                      class="select-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                    >
                      <option value="">Selecione</option>
                      <option value="champions">Campeões</option>
                      <option value="loyal">Leais</option>
                      <option value="potential_loyalists">Possíveis leais</option>
                      <option value="recent_customers">Novos</option>
                      <option value="promising">Promissores</option>
                      <option value="needs_attention">Precisam de atenção</option>
                      <option value="about_to_sleep">Prestes a dormir</option>
                      <option value="hibernating">Hibernando</option>
                      <option value="at_risk">Em risco</option>
                      <option value="cant_lose_them">Não pode perder</option>
                    </select>

                    <!-- Product -->
                    <template v-else-if="getFieldType(condition.field) === 'product'">
                      <!-- For "igual a" operator, show autocomplete -->
                      <div v-if="condition.operator === '='" class="autocomplete-wrapper">
                        <input
                          :value="getProductSearchQuery(groupIndex, condIndex)"
                          @input="handleProductSearch($event, groupIndex, condIndex)"
                          @focus="activeProductSearch = `${groupIndex}-${condIndex}`"
                          type="text"
                          class="input-field"
                          :class="{ 'has-error': hasFieldError(condition, 'valueUuid') }"
                          placeholder="Buscar produto..."
                        />

                        <!-- Dropdown de resultados -->
                        <div
                          v-if="isProductSearchActive(groupIndex, condIndex) && (productSearchResults.length > 0 || productSearchLoading)"
                          class="autocomplete-dropdown"
                        >
                          <div v-if="productSearchLoading" class="autocomplete-loading">
                            Buscando...
                          </div>
                          <div
                            v-else
                            v-for="product in productSearchResults"
                            :key="product.id"
                            @click="selectProduct(product, groupIndex, condIndex)"
                            class="autocomplete-item"
                          >
                            <img
                              v-if="product.imagem"
                              :src="product.imagem"
                              class="product-image"
                              alt=""
                            />
                            <div class="product-info">
                              <div class="product-name">{{ product.nome }}</div>
                              <div v-if="product.categoria" class="product-category">
                                {{ product.categoria }}
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>

                      <!-- For "contém" and "começa com" operators, show text input -->
                      <input
                        v-else
                        v-model="condition.valueText"
                        type="text"
                        class="input-field"
                        :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                        placeholder="Digite o nome do produto"
                      />
                    </template>

                    <!-- Category -->
                    <template v-else-if="getFieldType(condition.field) === 'category'">
                      <!-- For "igual a" operator, show autocomplete -->
                      <div v-if="condition.operator === '='" class="autocomplete-wrapper">
                        <input
                          :value="getCategorySearchQuery(groupIndex, condIndex)"
                          @input="handleCategorySearch($event, groupIndex, condIndex)"
                          @focus="activeCategorySearch = `${groupIndex}-${condIndex}`"
                          type="text"
                          class="input-field"
                          :class="{ 'has-error': hasFieldError(condition, 'valueUuid') }"
                          placeholder="Buscar categoria..."
                        />

                        <!-- Dropdown de resultados -->
                        <div
                          v-if="isCategorySearchActive(groupIndex, condIndex) && (categorySearchResults.length > 0 || categorySearchLoading)"
                          class="autocomplete-dropdown"
                        >
                          <div v-if="categorySearchLoading" class="autocomplete-loading">
                            Buscando...
                          </div>
                          <div
                            v-else
                            v-for="category in categorySearchResults"
                            :key="category.id"
                            @click="selectCategory(category, groupIndex, condIndex)"
                            class="autocomplete-item"
                          >
                            <div class="category-name-simple">{{ category.nome }}</div>
                          </div>
                        </div>
                      </div>

                      <!-- For "contém" and "começa com" operators, show text input -->
                      <input
                        v-else
                        v-model="condition.valueText"
                        type="text"
                        class="input-field"
                        :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                        placeholder="Digite o nome da categoria"
                      />
                    </template>

                    <!-- Color (variation_color) -->
                    <select
                      v-else-if="condition.field === 'variation_color'"
                      v-model="condition.valueText"
                      @focus="loadAllColors"
                      @change="updateSegmentData"
                      class="select-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                    >
                      <option value="">Selecione uma cor</option>
                      <option v-for="color in allColors" :key="color" :value="color">
                        {{ color }}
                      </option>
                    </select>

                    <!-- Size (variation_size) -->
                    <select
                      v-else-if="condition.field === 'variation_size'"
                      v-model="condition.valueText"
                      @focus="loadAllSizes"
                      @change="updateSegmentData"
                      class="select-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                    >
                      <option value="">Selecione um tamanho</option>
                      <option v-for="size in allSizes" :key="size" :value="size">
                        {{ size }}
                      </option>
                    </select>

                    <!-- Text -->
                    <input
                      v-else-if="getFieldType(condition.field) === 'text'"
                      v-model="condition.valueText"
                      type="text"
                      class="input-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                      placeholder="Digite"
                    />

                    <!-- Boolean -->
                    <select
                      v-else-if="getFieldType(condition.field) === 'boolean'"
                      v-model.number="condition.valueMin"
                      class="select-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueMin') }"
                    >
                      <option :value="1">Sim</option>
                      <option :value="0">Não</option>
                    </select>

                    <!-- UUID -->
                    <input
                      v-else-if="getFieldType(condition.field) === 'uuid'"
                      v-model="condition.valueUuid"
                      type="text"
                      class="input-field"
                      :class="{ 'has-error': hasFieldError(condition, 'valueUuid') }"
                      placeholder="ID"
                    />

                    <!-- Date -->
                    <template v-else-if="getFieldType(condition.field) === 'date'">
                      <!-- For "entre datas" operator, show date pickers -->
                      <template v-if="condition.operator === 'between_dates'">
                        <div class="date-picker-wrapper">
                          <input
                            :value="getDisplayDate(groupIndex, condIndex, 'startDate')"
                            @click="openDatePicker(groupIndex, condIndex, 'startDate')"
                            type="text"
                            placeholder="dd/mm/yy"
                            readonly
                            class="input-date"
                            :class="{ 'has-error': hasFieldError(condition, 'startDate') }"
                          />
                          <input
                            :ref="el => setDatePickerRef(groupIndex, condIndex, 'startDate', el)"
                            v-model="condition.startDate"
                            @change="updateSegmentData"
                            type="date"
                            :max="condition.endDate || undefined"
                            class="hidden-date-picker"
                          />
                        </div>
                        <span class="text-label">e</span>
                        <div class="date-picker-wrapper">
                          <input
                            :value="getDisplayDate(groupIndex, condIndex, 'endDate')"
                            @click="openDatePicker(groupIndex, condIndex, 'endDate')"
                            type="text"
                            placeholder="dd/mm/yy"
                            readonly
                            class="input-date"
                            :class="{ 'has-error': hasFieldError(condition, 'endDate') }"
                          />
                          <input
                            :ref="el => setDatePickerRef(groupIndex, condIndex, 'endDate', el)"
                            v-model="condition.endDate"
                            @change="updateSegmentData"
                            type="date"
                            :min="condition.startDate || undefined"
                            class="hidden-date-picker"
                          />
                        </div>
                      </template>

                      <!-- For other operators (in_the_next, in_the_last), show days input -->
                      <template v-else>
                        <input
                          v-model.number="condition.days"
                          type="number"
                          min="0"
                          class="input-small"
                          :class="{ 'has-error': hasFieldError(condition, 'days') }"
                          placeholder="Dias"
                        />
                        <span class="text-label">dias</span>
                      </template>
                    </template>

                    <!-- Birthday Range (Período de Aniversário) -->
                    <template v-else-if="getFieldType(condition.field) === 'birthday_range'">
                      <div class="date-picker-wrapper">
                        <input
                          :value="getBirthdayDisplayDate(condition, 'start')"
                          @click="openBirthdayPicker(groupIndex, condIndex, 'start')"
                          type="text"
                          placeholder="dd/mm"
                          readonly
                          class="input-date"
                          :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                        />
                        <input
                          :ref="el => setBirthdayPickerRef(groupIndex, condIndex, 'start', el)"
                          @change="handleBirthdayDateChange(groupIndex, condIndex, 'start', $event)"
                          type="date"
                          class="hidden-date-picker"
                        />
                      </div>
                      <span class="text-label">e</span>
                      <div class="date-picker-wrapper">
                        <input
                          :value="getBirthdayDisplayDate(condition, 'end')"
                          @click="openBirthdayPicker(groupIndex, condIndex, 'end')"
                          type="text"
                          placeholder="dd/mm"
                          readonly
                          class="input-date"
                          :class="{ 'has-error': hasFieldError(condition, 'valueText') }"
                        />
                        <input
                          :ref="el => setBirthdayPickerRef(groupIndex, condIndex, 'end', el)"
                          @change="handleBirthdayDateChange(groupIndex, condIndex, 'end', $event)"
                          type="date"
                          class="hidden-date-picker"
                        />
                      </div>
                    </template>
                  </template>

                  <!-- Temporal Filter -->
                  <select
                    v-if="condition.field && supportsTemporalFilter(condition.field)"
                    v-model="condition.timeOperator"
                    class="select-field"
                  >
                    <option value="over_all_time">desde sempre</option>
                    <option value="in_the_last">nos últimos X dias</option>
                    <option value="between_dates">entre datas</option>
                  </select>

                  <!-- Days for temporal -->
                  <template v-if="condition.timeOperator === 'in_the_last'">
                    <input
                      v-model.number="condition.days"
                      type="number"
                      min="0"
                      class="input-small"
                      :class="{ 'has-error': hasFieldError(condition, 'days') }"
                      placeholder="30"
                    />
                    <span class="text-label">dias</span>
                  </template>

                  <!-- Date range for temporal -->
                  <template v-if="condition.timeOperator === 'between_dates'">
                    <div class="date-picker-wrapper">
                      <input
                        :value="getDisplayDate(groupIndex, condIndex, 'startDate')"
                        @click="openDatePicker(groupIndex, condIndex, 'startDate')"
                        type="text"
                        placeholder="dd/mm/yy"
                        readonly
                        class="input-date"
                        :class="{ 'has-error': hasFieldError(condition, 'startDate') }"
                      />
                      <input
                        :ref="el => setDatePickerRef(groupIndex, condIndex, 'startDate', el)"
                        v-model="condition.startDate"
                        @change="updateSegmentData"
                        type="date"
                        :max="condition.endDate || undefined"
                        class="hidden-date-picker"
                      />
                    </div>
                    <span class="text-label">e</span>
                    <div class="date-picker-wrapper">
                      <input
                        :value="getDisplayDate(groupIndex, condIndex, 'endDate')"
                        @click="openDatePicker(groupIndex, condIndex, 'endDate')"
                        type="text"
                        placeholder="dd/mm/yy"
                        readonly
                        class="input-date"
                        :class="{ 'has-error': hasFieldError(condition, 'endDate') }"
                      />
                      <input
                        :ref="el => setDatePickerRef(groupIndex, condIndex, 'endDate', el)"
                        v-model="condition.endDate"
                        @change="updateSegmentData"
                        type="date"
                        :min="condition.startDate || undefined"
                        class="hidden-date-picker"
                      />
                    </div>
                  </template>

                  <!-- Metrics Checkbox (only for product and category) -->
                  <template v-if="getFieldType(condition.field) === 'product' || getFieldType(condition.field) === 'category'">
                    <div class="metrics-checkbox-wrapper">
                      <input
                        type="checkbox"
                        v-model="condition.enableMetrics"
                        :id="`metrics-${groupIndex}-${condIndex}`"
                      />
                      <label :for="`metrics-${groupIndex}-${condIndex}`" class="metrics-checkbox-label">
                        + Métricas
                      </label>
                    </div>
                  </template>

                  <!-- Delete Button -->
                  <button
                    @click="removeCondition(groupIndex, condIndex)"
                    class="btn-delete"
                    type="button"
                    title="Remover"
                  >
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M2 4H14M12.6667 4V13.3333C12.6667 14 12 14.6667 11.3333 14.6667H4.66667C4 14.6667 3.33333 14 3.33333 13.3333V4M5.33333 4V2.66667C5.33333 2 6 1.33333 6.66667 1.33333H9.33333C10 1.33333 10.6667 2 10.6667 2.66667V4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M6.66667 7.33334V11.3333" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M9.33333 7.33334V11.3333" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                  </button>
                  </div>

                  <!-- Metrics Section (shown when checkbox is enabled for product/category) -->
                  <div
                    v-if="(getFieldType(condition.field) === 'product' || getFieldType(condition.field) === 'category') && condition.enableMetrics"
                    class="metrics-section-expanded"
                  >
                    <!-- Quantity -->
                    <div class="metric-row">
                      <input
                        type="checkbox"
                        v-model="condition.metricCount.enabled"
                        :id="`metric-count-${groupIndex}-${condIndex}`"
                      />
                      <label :for="`metric-count-${groupIndex}-${condIndex}`" class="metric-label">
                        Quantidade de compras:
                      </label>
                      <select
                        v-model="condition.metricCount.operator"
                        class="select-field-tiny"
                        :disabled="!condition.metricCount.enabled"
                      >
                        <option value=">=">maior ou igual a</option>
                        <option value="<=">menor ou igual a</option>
                        <option value="=">igual a</option>
                      </select>
                      <input
                        v-model.number="condition.metricCount.value"
                        type="number"
                        min="0"
                        class="input-tiny"
                        :disabled="!condition.metricCount.enabled"
                        placeholder="Ex: 3"
                      />
                    </div>

                    <!-- Value -->
                    <div class="metric-row">
                      <input
                        type="checkbox"
                        v-model="condition.metricValue.enabled"
                        :id="`metric-value-${groupIndex}-${condIndex}`"
                      />
                      <label :for="`metric-value-${groupIndex}-${condIndex}`" class="metric-label">
                        Valor total gasto:
                      </label>
                      <select
                        v-model="condition.metricValue.operator"
                        class="select-field-tiny"
                        :disabled="!condition.metricValue.enabled"
                      >
                        <option value=">=">maior ou igual a</option>
                        <option value="<=">menor ou igual a</option>
                        <option value="=">igual a</option>
                      </select>
                      <input
                        v-model.number="condition.metricValue.value"
                        type="number"
                        min="0"
                        class="input-tiny"
                        :disabled="!condition.metricValue.enabled"
                        placeholder="Ex: 1000"
                      />
                    </div>

                    <!-- Recency -->
                    <div class="metric-row">
                      <input
                        type="checkbox"
                        v-model="condition.metricRecency.enabled"
                        :id="`metric-recency-${groupIndex}-${condIndex}`"
                      />
                      <label :for="`metric-recency-${groupIndex}-${condIndex}`" class="metric-label">
                        Última compra há:
                      </label>
                      <select
                        v-model="condition.metricRecency.operator"
                        class="select-field-tiny"
                        :disabled="!condition.metricRecency.enabled"
                      >
                        <option value=">=">maior ou igual a</option>
                        <option value="<=">menor ou igual a</option>
                        <option value="=">igual a</option>
                      </select>
                      <input
                        v-model.number="condition.metricRecency.value"
                        type="number"
                        min="0"
                        class="input-tiny"
                        :disabled="!condition.metricRecency.enabled"
                        placeholder="Ex: 30"
                      />
                      <span class="text-label">dias</span>
                    </div>
                  </div>
                </div>
              </template>

              <!-- Add OU button and Group delete button -->
              <div class="group-actions">
                <button
                  @click="addCondition(groupIndex)"
                  class="btn-add-condition"
                  type="button"
                >
                  <span class="plus-icon">+</span> OU
                </button>
                <button
                  @click="removeGroup(groupIndex)"
                  class="btn-delete"
                  type="button"
                  title="Remover grupo"
                >
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M2 4H14M12.6667 4V13.3333C12.6667 14 12 14.6667 11.3333 14.6667H4.66667C4 14.6667 3.33333 14 3.33333 13.3333V4M5.33333 4V2.66667C5.33333 2 6 1.33333 6.66667 1.33333H9.33333C10 1.33333 10.6667 2 10.6667 2.66667V4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M6.66667 7.33334V11.3333" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M9.33333 7.33334V11.3333" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </button>
              </div>
            </div>

            <!-- E Label between groups -->
            <div v-if="groupIndex < groups.length - 1" class="label-e">E</div>
          </template>

          <!-- Add E button outside groups -->
          <button @click="addGroup" class="btn-add-group" type="button">
            <span class="plus-icon">+</span> E
          </button>
        </div>

        <!-- Filter Description -->
        <div v-if="hasCompleteConditions" class="filter-description-section">
          <h3 class="description-title">
            Este segmento contém clientes que atendem as seguintes condições
          </h3>

          <div class="description-content">
            <div class="description-groups">
              <template v-for="(group, groupIndex) in completeGroups" :key="`desc-group-${group.groupNumber}`">
                <div class="description-group">
                  <div class="group-header">
                    <span class="group-number">{{ groupIndex + 1 }}.</span>
                    <span class="group-text">
                      <span v-if="group.conditions.length > 1">Pelo menos UMA das seguintes condições:</span>
                      <span v-else>A seguinte condição:</span>
                    </span>
                  </div>

                  <ul class="conditions-list">
                    <li
                      v-for="(condition, condIndex) in group.conditions"
                      :key="`desc-cond-${groupIndex}-${condIndex}`"
                      class="condition-item"
                    >
                      {{ formatConditionDescription(condition, groupIndex, condIndex) }}
                    </li>
                  </ul>
                </div>

                <div v-if="groupIndex < completeGroups.length - 1" class="group-separator">
                  E TAMBÉM
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';

export default {
  props: {
    uid: { type: String, required: true },
    content: { type: Object, required: true },
    /* wwEditor:start */
    wwEditorState: { type: Object, required: true },
    /* wwEditor:end */
  },
  emits: ['trigger-event'],
  setup(props, { emit }) {
    // Field Definitions
    const FIELD_DEFINITIONS = {
      // v1 - Comportamento Básico
      frequency: { type: 'numeric', label: 'Número de pedidos', temporal: true },
      total_value: { type: 'numeric', label: 'Valor Total Gasto', temporal: true },
      recencia: { type: 'numeric', label: 'Dias Desde Última Compra', temporal: true },

      // v2 - Demografia
      age: { type: 'numeric', label: 'Idade', temporal: false },
      birthday_period: { type: 'birthday_range', label: 'Período de Aniversário', temporal: false },
      gender: { type: 'select', label: 'Gênero', temporal: false },
      location_city: { type: 'text', label: 'Cidade', temporal: false },
      location_state: { type: 'text', label: 'Estado', temporal: false },
      opt_in_sms: { type: 'boolean', label: 'Opt-in SMS', temporal: false },
      opt_in_email: { type: 'boolean', label: 'Opt-in Email', temporal: false },
      opt_in_whatsapp: { type: 'boolean', label: 'Opt-in WhatsApp', temporal: false },

      // v2 - Cashback
      cashback_last_status: { type: 'select', label: 'Status do Último Cashback', temporal: false },
      cashback_last_value: { type: 'numeric', label: 'Valor do Último Cashback', temporal: false },
      cashback_expiry_date: { type: 'date', label: 'Data de Vencimento do Cashback', temporal: false },
      cashback_creation_date: { type: 'date', label: 'Data de Criação do Cashback', temporal: false },

      // v2 - RFM
      rfm_segment: { type: 'select', label: 'Segmento RFM', temporal: false },

      // v3 - Produtos
      produto: { type: 'product', label: 'Produto', temporal: true },
      categoria: { type: 'category', label: 'Categoria', temporal: true },
      // product_criteria: { type: 'product_criteria', label: 'Critério de Produto', temporal: true },
      // product_id: { type: 'uuid', label: 'Produto Específico', temporal: true },
      // product_name: { type: 'text', label: 'Nome do Produto', temporal: true },
      // product_sku: { type: 'text', label: 'SKU do Produto', temporal: true },
      // product_brand: { type: 'text', label: 'Marca', temporal: true },
      // product_category_id: { type: 'uuid', label: 'Categoria (com hierarquia)', temporal: true },
      // product_category_name: { type: 'text', label: 'Nome da Categoria', temporal: true },
      variation_color: { type: 'text', label: 'Cor', temporal: true },
      variation_size: { type: 'text', label: 'Tamanho', temporal: true },
      // variation_material: { type: 'text', label: 'Material', temporal: true },
      product_purchase_count: { type: 'numeric', label: 'Quantidade de Compras', temporal: true },
      product_purchase_value: { type: 'numeric', label: 'Valor Total Gasto em Produtos', temporal: true },
      product_purchase_recency: { type: 'numeric', label: 'Dias Desde Última Compra de Produto', temporal: false },
    };

    const fieldCategories = [
      {
        label: 'Comportamento',
        fields: [
          { value: 'frequency', label: 'Número de pedidos' },
          { value: 'total_value', label: 'Valor Total Gasto' },
          { value: 'recencia', label: 'Dias Desde Última Compra' },
        ],
      },
      {
        label: 'Demografia',
        fields: [
          { value: 'age', label: 'Idade' },
          { value: 'birthday_period', label: 'Período de Aniversário' },
          { value: 'gender', label: 'Gênero' },
          { value: 'location_city', label: 'Cidade' },
          { value: 'location_state', label: 'Estado' },
          { value: 'opt_in_sms', label: 'Opt-in SMS' },
          { value: 'opt_in_email', label: 'Opt-in Email' },
          { value: 'opt_in_whatsapp', label: 'Opt-in WhatsApp' },
        ],
      },
      {
        label: 'Cashback',
        fields: [
          { value: 'cashback_last_status', label: 'Status do Último Cashback' },
          { value: 'cashback_last_value', label: 'Valor do Último Cashback' },
          { value: 'cashback_expiry_date', label: 'Data de Vencimento do Cashback' },
          { value: 'cashback_creation_date', label: 'Data de Criação do Cashback' },
        ],
      },
      {
        label: 'RFM',
        fields: [
          { value: 'rfm_segment', label: 'Segmento RFM' },
        ],
      },
      {
        label: 'Produtos',
        fields: [
          { value: 'produto', label: 'Produto' },
          { value: 'categoria', label: 'Categoria' },
          // { value: 'product_criteria', label: 'Critério de Produto' },
          // { value: 'product_id', label: 'Produto Específico' },
          // { value: 'product_name', label: 'Nome do Produto' },
          // { value: 'product_sku', label: 'SKU do Produto' },
          // { value: 'product_brand', label: 'Marca' },
          // { value: 'product_category_id', label: 'Categoria (com hierarquia)' },
          // { value: 'product_category_name', label: 'Nome da Categoria' },
          { value: 'variation_color', label: 'Cor' },
          { value: 'variation_size', label: 'Tamanho' },
          // { value: 'variation_material', label: 'Material' },
          // { value: 'product_purchase_count', label: 'Quantidade de Compras' },
          // { value: 'product_purchase_value', label: 'Valor Total Gasto em Produtos' },
          // { value: 'product_purchase_recency', label: 'Dias Desde Última Compra de Produto' },
        ],
      },
    ];

    // Helper functions (defined first to avoid hoisting issues)
    function createNewCondition() {
      return {
        field: '',
        operator: '',
        valueText: '',
        valueUuid: '',
        valueMin: null,
        valueMax: null,
        valueList: [],
        timeOperator: 'over_all_time',
        days: null,
        startDate: '',
        endDate: '',
        // Product Criteria specific fields
        productType: 'produto', // 'produto' or 'categoria'
        productOperator: '=',
        productValue: '',
        enableMetrics: false,
        metricCount: { enabled: false, operator: '>=', value: null },
        metricValue: { enabled: false, operator: '>=', value: null },
        metricRecency: { enabled: false, operator: '>=', value: null },
      };
    }

    function createNewGroup(groupNumber) {
      return {
        groupNumber,
        conditions: [createNewCondition()],
      };
    }

    // Reactive state
    const segmentName = ref('');
    const segmentDescription = ref('');
    const groups = ref([createNewGroup(1)]);
    const showValidation = ref(false);
    const isSaving = ref(false);

    // Computed para detectar modo edição
    const isEditMode = computed(() => {
      return !!props.content?.segmentId;
    });

    const pageTitle = computed(() => {
      return isEditMode.value ? 'Editar Segmento' : 'Criar Segmento';
    });

    // Product autocomplete state
    const productSearchResults = ref([]);
    const productSearchQuery = ref({});
    const activeProductSearch = ref(null);
    const productSearchLoading = ref(false);

    // Category autocomplete state
    const categorySearchResults = ref([]);
    const categorySearchQuery = ref({});
    const activeCategorySearch = ref(null);
    const categorySearchLoading = ref(false);
    const allCategories = ref([]); // Cache de todas as categorias

    // Color and Size dropdown state
    const allColors = ref([]); // Cache de todas as cores
    const allSizes = ref([]); // Cache de todos os tamanhos

    // Close autocomplete when clicking outside
    const handleClickOutside = (event) => {
      if (!event.target.closest('.autocomplete-wrapper')) {
        closeProductSearch();
        closeCategorySearch();
      }
    };

    // Carregar segmento da URL se houver ID
    async function loadSegmentFromUrl() {
      try {
        // Obter ID do segmento da propriedade (bindada ao query parameter)
        const segmentoId = props.content?.segmentId;

        if (!segmentoId) {
          console.log('Nenhum ID de segmento - modo criação');
          return;
        }

        console.log('📥 Carregando segmento ID:', segmentoId);

        if (!empresaId.value) {
          console.error('Empresa ID não disponível para carregar segmento');
          return;
        }

        const supabaseClient = wwLib.wwPlugins.supabaseAuth?.publicInstance;

        if (!supabaseClient) {
          throw new Error('Supabase client not available');
        }

        // Chamar RPC front_segmento_carregar_editar
        const { data, error } = await supabaseClient.rpc('front_segmento_carregar_editar', {
          payload: {
            segmento: parseInt(segmentoId),
            empresa: empresaId.value
          }
        });

        if (error) {
          console.error('❌ Erro ao carregar segmento:', error);
          throw error;
        }

        console.log('✅ Segmento carregado:', data);

        if (data) {
          // Preencher os campos com os dados do segmento
          populateSegmentData(data);
        }

      } catch (error) {
        console.error('❌ Erro ao carregar segmento da URL:', error);
      }
    }

    // Preencher o componente com dados do segmento carregado
    function populateSegmentData(segmentData) {
      try {
        console.log('📝 Preenchendo dados do segmento:', segmentData);

        // Preencher nome e descrição
        segmentName.value = segmentData.nome || '';
        segmentDescription.value = segmentData.descricao || '';

        // Preencher grupos e condições
        if (segmentData.groups && Array.isArray(segmentData.groups)) {
          groups.value = segmentData.groups.map((group, groupIdx) => ({
            groupNumber: groupIdx + 1,
            conditions: group.conditions.map((condition, condIdx) => {
              // Converter condição do formato do backend para o formato do frontend
              console.log(`🔍 Condition ${groupIdx}-${condIdx}:`, condition);
              const frontendCondition = createNewCondition();

              frontendCondition.field = condition.field;
              frontendCondition.operator = condition.operator;

              // Preencher valores baseado no tipo de campo
              if (condition.valueText !== undefined) {
                frontendCondition.valueText = condition.valueText;
              }
              if (condition.valueUuid !== undefined) {
                frontendCondition.valueUuid = condition.valueUuid;
              }
              if (condition.valueMin !== undefined) {
                frontendCondition.valueMin = condition.valueMin;
              }
              if (condition.valueMax !== undefined) {
                frontendCondition.valueMax = condition.valueMax;
              }
              if (condition.valueList !== undefined) {
                frontendCondition.valueList = condition.valueList;
              }

              // Preencher filtros temporais
              if (condition.timeOperator !== undefined) {
                frontendCondition.timeOperator = condition.timeOperator;
              }
              if (condition.days !== undefined) {
                frontendCondition.days = condition.days;
              }
              if (condition.startDate !== undefined) {
                frontendCondition.startDate = condition.startDate;
              }
              if (condition.endDate !== undefined) {
                frontendCondition.endDate = condition.endDate;
              }

              // Preencher cache de autocomplete para produtos e categorias
              const key = `${groupIdx}-${condIdx}`;

              // Se for produto e tiver nome, adicionar ao cache
              if (condition.field === 'produto' && condition.productName) {
                productSearchQuery.value[key] = condition.productName;
              }

              // Se for categoria e tiver nome, adicionar ao cache
              if (condition.field === 'categoria' && condition.categoryName) {
                categorySearchQuery.value[key] = condition.categoryName;
              }

              return frontendCondition;
            })
          }));

          console.log('✅ Grupos preenchidos:', groups.value.length);
        }

        // Atualizar dados do segmento
        updateSegmentData();

      } catch (error) {
        console.error('❌ Erro ao preencher dados do segmento:', error);
      }
    }

    onMounted(async () => {
      document.addEventListener('click', handleClickOutside);
    });

    onUnmounted(() => {
      document.removeEventListener('click', handleClickOutside);
    });

    // Computed empresa ID from user collection
    const empresaId = computed(() => {
      // Priority 1: Manual override
      if (props.content?.empresaId) {
        return props.content.empresaId;
      }

      // Priority 2: Get from bound user collection prop
      const userCollection = props.content?.userCollection;
      if (Array.isArray(userCollection) && userCollection.length > 0) {
        const userData = userCollection[0];
        if (userData?.empresa) {
          return userData.empresa;
        }
      }

      // Priority 3: Access directly from WeWeb collections store
      try {
        const collections = wwLib.$store.getters['data/getCollections'];
        const empresa = collections?.['2a7ebac6-154a-4af7-8337-411e42e6a35c']?.data?.[0]?.empresa;
        if (empresa) {
          return empresa;
        }
      } catch (error) {
        console.error('Error accessing collections:', error);
      }

      // No data available
      return undefined;
    });

    // Watch for segmentId changes (after empresaId is defined)
    watch(() => props.content?.segmentId, async (newId, oldId) => {
      if (newId && newId !== oldId) {
        console.log('🔄 Segment ID changed:', newId);
        await loadSegmentFromUrl();
      }
    }, { immediate: true });

    const { value: segmentData, setValue: setSegmentData } = wwLib.wwVariable.useComponentVariable({
      uid: props.uid,
      name: 'segmentData',
      type: 'object',
      defaultValue: {},
    });

    // Validation functions
    function isConditionComplete(condition) {
      if (!condition.field || !condition.operator) return false;

      const fieldType = getFieldType(condition.field);

      // Check value fields based on type
      if (fieldType === 'numeric') {
        if (condition.operator === 'between') {
          if (condition.valueMin === null || condition.valueMin === undefined ||
              condition.valueMax === null || condition.valueMax === undefined) {
            return false;
          }
        } else {
          if (condition.valueMin === null || condition.valueMin === undefined) {
            return false;
          }
        }
      } else if (fieldType === 'text') {
        if (!condition.valueText || condition.valueText.trim() === '') return false;
      } else if (fieldType === 'uuid') {
        if (!condition.valueUuid || condition.valueUuid.trim() === '') return false;
      } else if (fieldType === 'date') {
        if (condition.operator === 'between_dates') {
          if (!condition.startDate || !condition.endDate) return false;
        } else if (!condition.days) {
          return false;
        }
      }

      // Check temporal filter if applicable
      if (supportsTemporalFilter(condition.field)) {
        if (condition.timeOperator === 'in_the_last') {
          if (!condition.days) return false;
        } else if (condition.timeOperator === 'between_dates') {
          if (!condition.startDate || !condition.endDate) return false;
        }
      }

      return true;
    }

    const canSave = computed(() => {
      return (
        segmentName.value.trim().length > 0 &&
        groups.value.length > 0 &&
        groups.value.every(g =>
          g.conditions.length > 0 &&
          g.conditions.every(c => isConditionComplete(c))
        )
      );
    });

    // Check if there's at least one complete condition
    const hasCompleteConditions = computed(() => {
      return groups.value.some(group =>
        group.conditions.some(condition => isConditionComplete(condition))
      );
    });

    // Filter to show only groups with complete conditions
    const completeGroups = computed(() => {
      return groups.value
        .map(group => ({
          ...group,
          conditions: group.conditions.filter(condition => isConditionComplete(condition))
        }))
        .filter(group => group.conditions.length > 0);
    });

    const filterDescription = computed(() => {
      if (groups.value.length === 0) {
        return 'Nenhuma condição definida';
      }

      const groupDescriptions = groups.value.map((group, groupIndex) => {
        if (group.conditions.length === 0) {
          return '[Grupo vazio]';
        }

        const conditionDescriptions = group.conditions.map((condition, condIndex) =>
          formatConditionDescription(condition, groupIndex, condIndex)
        );

        // Join conditions with "OU" if more than one
        if (conditionDescriptions.length === 1) {
          return conditionDescriptions[0];
        } else {
          return `(${conditionDescriptions.join(' OU ')})`;
        }
      });

      // Join groups with "E"
      return `Clientes que: ${groupDescriptions.join(' E ')}`;
    });

    function getFieldType(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      return field?.type || 'text';
    }

    function getOperatorsForField(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      if (!field) return [];

      const operatorsByType = {
        numeric: [
          { value: '>=', label: 'maior ou igual a' },
          { value: '<=', label: 'menor ou igual a' },
          { value: '=', label: 'igual a' },
          { value: 'between', label: 'entre' },
        ],
        text: [
          { value: '=', label: 'igual a' },
          { value: 'contains', label: 'contém' },
          { value: 'starts_with', label: 'começa com' },
        ],
        select: [
          { value: '=', label: 'igual a' },
        ],
        product: [
          { value: '=', label: 'igual a' },
          { value: 'contains', label: 'contém' },
          { value: 'starts_with', label: 'começa com' },
        ],
        category: [
          { value: '=', label: 'igual a' },
          { value: 'contains', label: 'contém' },
          { value: 'starts_with', label: 'começa com' },
        ],
        uuid: [{ value: '=', label: 'igual a' }],
        boolean: [{ value: '=', label: 'é' }],
        date: [
          { value: 'in_the_next', label: 'nos próximos' },
          { value: 'in_the_last', label: 'nos últimos' },
          { value: 'between_dates', label: 'entre datas' },
        ],
        birthday_range: [
          { value: '=', label: 'entre datas' },
        ],
      };

      return operatorsByType[field.type] || [];
    }

    function supportsTemporalFilter(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      return field?.temporal === true;
    }

    // Description formatting functions
    function getFieldLabel(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      return field?.label || fieldName;
    }

    function getOperatorLabel(operator, fieldType) {
      const operatorLabels = {
        '>=': 'maior ou igual a',
        '<=': 'menor ou igual a',
        '=': 'igual a',
        'between': 'entre',
        'contains': 'contém',
        'starts_with': 'começa com',
        'in_the_next': 'nos próximos',
        'in_the_last': 'nos últimos',
        'between_dates': 'entre as datas',
      };
      return operatorLabels[operator] || operator;
    }

    function getTimeOperatorLabel(timeOperator) {
      const labels = {
        'over_all_time': 'desde sempre',
        'in_the_last': 'nos últimos',
        'between_dates': 'entre as datas',
      };
      return labels[timeOperator] || timeOperator;
    }

    function formatConditionValue(condition, groupIndex, condIndex) {
      const fieldType = getFieldType(condition.field);

      if (fieldType === 'numeric') {
        if (condition.operator === 'between') {
          return `${condition.valueMin || '?'} e ${condition.valueMax || '?'}`;
        }
        return `${condition.valueMin !== null && condition.valueMin !== undefined ? condition.valueMin : '?'}`;
      } else if (condition.field === 'variation_color' || condition.field === 'variation_size') {
        // Para cores e tamanhos, mostrar o valor selecionado
        return condition.valueText ? `"${condition.valueText}"` : '"?"';
      } else if (fieldType === 'text') {
        return `"${condition.valueText || '?'}"`;
      } else if (fieldType === 'product') {
        // Para produtos, mostrar o nome do cache de busca
        const key = `${groupIndex}-${condIndex}`;
        const productName = productSearchQuery.value[key];
        if (productName) {
          return `"${productName}"`;
        }
        return condition.valueText ? `"${condition.valueText}"` : '"?"';
      } else if (fieldType === 'category') {
        // Para categorias, mostrar o nome do cache de busca
        const key = `${groupIndex}-${condIndex}`;
        const categoryName = categorySearchQuery.value[key];
        if (categoryName) {
          return `"${categoryName}"`;
        }
        return condition.valueText ? `"${condition.valueText}"` : '"?"';
      } else if (fieldType === 'uuid') {
        return `"${condition.valueUuid || '?'}"`;
      } else if (fieldType === 'boolean') {
        return condition.valueMin === 1 ? 'Sim' : condition.valueMin === 0 ? 'Não' : '?';
      } else if (fieldType === 'date') {
        if (condition.operator === 'between_dates') {
          return `entre ${formatDate(condition.startDate)} e ${formatDate(condition.endDate)}`;
        }
        return `${condition.days || '?'} dias`;
      }

      return '?';
    }

    function formatDate(dateString) {
      if (!dateString) return '?';
      const date = new Date(dateString);
      const day = String(date.getDate()).padStart(2, '0');
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const year = String(date.getFullYear()).slice(-2);
      return `${day}/${month}/${year}`;
    }

    function formatTemporalFilter(condition) {
      if (!supportsTemporalFilter(condition.field)) return '';

      if (condition.timeOperator === 'over_all_time') {
        return ' desde sempre';
      } else if (condition.timeOperator === 'in_the_last') {
        return ` nos últimos ${condition.days || '?'} dias`;
      } else if (condition.timeOperator === 'between_dates') {
        return ` entre ${formatDate(condition.startDate)} e ${formatDate(condition.endDate)}`;
      }

      return '';
    }

    function formatConditionDescription(condition, groupIndex, condIndex) {
      if (!condition.field || !condition.operator) {
        return '[Condição incompleta]';
      }

      const fieldLabel = getFieldLabel(condition.field);
      const operatorLabel = getOperatorLabel(condition.operator, getFieldType(condition.field));
      const value = formatConditionValue(condition, groupIndex, condIndex);
      const temporal = formatTemporalFilter(condition);

      return `${fieldLabel} ${operatorLabel} ${value}${temporal}`;
    }

    function addGroup() {
      const newGroupNumber = groups.value.length + 1;
      groups.value.push(createNewGroup(newGroupNumber));
      updateSegmentData();
    }

    function removeGroup(index) {
      if (groups.value.length <= 1) return;
      groups.value.splice(index, 1);
      groups.value.forEach((group, idx) => {
        group.groupNumber = idx + 1;
      });
      updateSegmentData();
    }

    function addCondition(groupIndex) {
      groups.value[groupIndex].conditions.push(createNewCondition());
      updateSegmentData();
    }

    function removeCondition(groupIndex, conditionIndex) {
      const group = groups.value[groupIndex];
      if (group.conditions.length <= 1) {
        removeGroup(groupIndex);
      } else {
        group.conditions.splice(conditionIndex, 1);
        updateSegmentData();
      }
    }

    // Date picker refs storage
    const datePickerRefs = ref({});
    const birthdayPickerRefs = ref({});

    // Date formatting helper
    function formatDateToBR(isoDate) {
      if (!isoDate) return '';
      // Convert yyyy-mm-dd to dd/mm/yy
      const [year, month, day] = isoDate.split('-');
      const shortYear = year.slice(2); // Get last 2 digits of year
      return `${day}/${month}/${shortYear}`;
    }

    function getDisplayDate(groupIndex, condIndex, field) {
      const condition = groups.value[groupIndex]?.conditions[condIndex];
      if (!condition) return '';
      return formatDateToBR(condition[field]);
    }

    function setDatePickerRef(groupIndex, condIndex, field, el) {
      if (el) {
        const key = `${groupIndex}-${condIndex}-${field}`;
        datePickerRefs.value[key] = el;
      }
    }

    function openDatePicker(groupIndex, condIndex, field) {
      const key = `${groupIndex}-${condIndex}-${field}`;
      const pickerEl = datePickerRefs.value[key];
      if (pickerEl) {
        pickerEl.showPicker?.(); // Modern browsers
        pickerEl.click(); // Fallback
      }
    }

    // Birthday Range helpers
    function getBirthdayDisplayDate(condition, type) {
      if (!condition.valueText) return '';
      // Parse "MMDD-MMDD" format
      const parts = condition.valueText.split('-');
      if (parts.length !== 2) return '';

      const mmdd = type === 'start' ? parts[0] : parts[1];
      if (mmdd.length !== 4) return '';

      const month = mmdd.slice(0, 2);
      const day = mmdd.slice(2, 4);
      return `${day}/${month}`;
    }

    function setBirthdayPickerRef(groupIndex, condIndex, type, el) {
      if (el) {
        const key = `${groupIndex}-${condIndex}-birthday-${type}`;
        birthdayPickerRefs.value[key] = el;
      }
    }

    function openBirthdayPicker(groupIndex, condIndex, type) {
      const key = `${groupIndex}-${condIndex}-birthday-${type}`;
      const pickerEl = birthdayPickerRefs.value[key];
      if (pickerEl) {
        pickerEl.showPicker?.();
        pickerEl.click();
      }
    }

    function handleBirthdayDateChange(groupIndex, condIndex, type, event) {
      const condition = groups.value[groupIndex].conditions[condIndex];
      const selectedDate = event.target.value; // yyyy-mm-dd

      if (!selectedDate) return;

      const [year, month, day] = selectedDate.split('-');
      const mmdd = `${month}${day}`; // Format: MMDD

      // Parse existing valueText or create new
      let startMMDD = '';
      let endMMDD = '';

      if (condition.valueText && condition.valueText.includes('-')) {
        const parts = condition.valueText.split('-');
        startMMDD = parts[0] || '';
        endMMDD = parts[1] || '';
      }

      // Update the appropriate part
      if (type === 'start') {
        startMMDD = mmdd;
      } else {
        endMMDD = mmdd;
      }

      // Build the final valueText in "MMDD-MMDD" format
      if (startMMDD && endMMDD) {
        condition.valueText = `${startMMDD}-${endMMDD}`;
      } else if (startMMDD) {
        condition.valueText = `${startMMDD}-`;
      } else if (endMMDD) {
        condition.valueText = `-${endMMDD}`;
      }

      updateSegmentData();
    }

    function handleFieldChange(groupIndex, condIndex) {
      const condition = groups.value[groupIndex].conditions[condIndex];
      condition.operator = '';
      condition.valueText = '';
      condition.valueUuid = '';
      condition.valueMin = null;
      condition.valueMax = null;
      condition.timeOperator = 'over_all_time';
      updateSegmentData();
    }

    function handleOperatorChange(groupIndex, condIndex) {
      const condition = groups.value[groupIndex].conditions[condIndex];
      condition.valueText = '';
      condition.valueUuid = '';
      condition.valueMin = null;
      condition.valueMax = null;
      updateSegmentData();
    }

    function handleSegmentNameChange() {
      updateSegmentData();
    }

    function handleSegmentDescriptionChange() {
      updateSegmentData();
    }

    // Product autocomplete functions
    let productSearchTimeout = null;

    async function searchProducts(query, groupIndex, condIndex) {
      if (!query || query.trim().length < 2) {
        productSearchResults.value = [];
        return;
      }

      try {
        productSearchLoading.value = true;

        if (!empresaId.value) {
          throw new Error('Empresa ID não encontrado. Configure a propriedade empresaId ou vincule a collection do usuário.');
        }

        console.log('🔍 Buscando produtos:', query, 'Empresa:', empresaId.value);

        // Access Supabase client from WeWeb plugin
        const supabaseClient = wwLib.wwPlugins.supabaseAuth?.publicInstance;

        if (!supabaseClient) {
          throw new Error('Supabase client not available. Ensure Supabase plugin is configured.');
        }

        console.log('✅ Supabase client found');

        // Call Edge Function with query params in the URL
        const functionName = `produtos-search?q=${encodeURIComponent(query)}&empresa_id=${empresaId.value}&limit=20`;
        console.log('📡 Calling function:', functionName);

        const response = await supabaseClient.functions.invoke(functionName);

        console.log('📦 Full response:', response);

        if (response.error) {
          console.error('❌ Edge Function error:', response.error);

          // Try to read the error body
          try {
            const errorResponse = response.error.context;
            if (errorResponse && errorResponse.body) {
              const errorText = await errorResponse.text();
              console.error('❌ Error response body:', errorText);
              try {
                const errorJson = JSON.parse(errorText);
                console.error('❌ Error JSON:', errorJson);
              } catch (e) {
                // Not JSON, already logged as text
              }
            }
          } catch (e) {
            console.error('Could not read error body:', e);
          }

          throw response.error;
        }

        console.log('✅ Produtos encontrados:', response.data);

        const data = response.data;

        productSearchResults.value = Array.isArray(data) ? data : [];

      } catch (error) {
        console.error('❌ Erro na busca de produtos:', error);
        console.error('Stack:', error.stack);
        productSearchResults.value = [];

      } finally {
        productSearchLoading.value = false;
      }
    }

    function handleProductSearch(event, groupIndex, condIndex) {
      const query = event.target.value;

      // Update the search query for this specific field
      const key = `${groupIndex}-${condIndex}`;
      productSearchQuery.value[key] = query;
      activeProductSearch.value = key;

      // Clear existing timeout
      if (productSearchTimeout) {
        clearTimeout(productSearchTimeout);
      }

      // Set new timeout for debounced search
      productSearchTimeout = setTimeout(() => {
        searchProducts(query, groupIndex, condIndex);
      }, 300);
    }

    function selectProduct(product, groupIndex, condIndex) {
      const condition = groups.value[groupIndex].conditions[condIndex];
      condition.valueUuid = product.id;

      // Store product name in valueText for display
      const key = `${groupIndex}-${condIndex}`;
      productSearchQuery.value[key] = product.nome;

      // Close dropdown
      activeProductSearch.value = null;
      productSearchResults.value = [];

      updateSegmentData();
    }

    function closeProductSearch() {
      activeProductSearch.value = null;
      productSearchResults.value = [];
    }

    function getProductSearchQuery(groupIndex, condIndex) {
      const key = `${groupIndex}-${condIndex}`;
      return productSearchQuery.value[key] || '';
    }

    function isProductSearchActive(groupIndex, condIndex) {
      const key = `${groupIndex}-${condIndex}`;
      return activeProductSearch.value === key;
    }

    // Category autocomplete functions
    let categorySearchTimeout = null;

    // Função para achatar a árvore de categorias e criar o caminho
    function flattenCategoryTree(categories, parentPath = '') {
      const flattened = [];

      for (const category of categories) {
        const caminho = parentPath ? `${parentPath} > ${category.nome}` : category.nome;

        flattened.push({
          id: category.id,
          nome: category.nome,
          caminho: caminho
        });

        // Recursivamente adicionar filhos
        if (category.filhos && category.filhos.length > 0) {
          const childrenFlattened = flattenCategoryTree(category.filhos, caminho);
          flattened.push(...childrenFlattened);
        }
      }

      return flattened;
    }

    // Carregar todas as categorias da empresa
    async function loadAllCategories() {
      if (allCategories.value.length > 0) {
        return; // Já carregadas
      }

      try {
        if (!empresaId.value) {
          console.warn('Empresa ID não disponível para carregar categorias');
          return;
        }

        console.log('📂 Carregando árvore de categorias para empresa:', empresaId.value);

        const supabaseClient = wwLib.wwPlugins.supabaseAuth?.publicInstance;

        if (!supabaseClient) {
          throw new Error('Supabase client not available');
        }

        // Chamar Edge Function categorias-tree
        const functionName = `categorias-tree?empresa_id=${empresaId.value}`;
        console.log('📡 Calling function:', functionName);

        const response = await supabaseClient.functions.invoke(functionName);

        if (response.error) {
          console.error('❌ Erro ao carregar categorias:', response.error);
          throw response.error;
        }

        console.log('✅ Árvore de categorias carregada:', response.data);

        // Achatar a árvore - processar roots e orphaned
        const data = response.data || {};
        const roots = Array.isArray(data.roots) ? data.roots : [];
        const orphaned = Array.isArray(data.orphaned) ? data.orphaned : [];

        // Achatar roots
        const flattenedRoots = flattenCategoryTree(roots);

        // Achatar orphaned
        const flattenedOrphaned = flattenCategoryTree(orphaned);

        // Combinar tudo
        allCategories.value = [...flattenedRoots, ...flattenedOrphaned];

        console.log('✅ Categorias achatadas:', allCategories.value.length, '(roots:', roots.length, ', orphaned:', orphaned.length, ')');

      } catch (error) {
        console.error('❌ Erro ao carregar categorias:', error);
        allCategories.value = [];
      }
    }

    // Buscar categorias localmente
    async function searchCategories(query, groupIndex, condIndex) {
      if (!query || query.trim().length < 2) {
        categorySearchResults.value = [];
        return;
      }

      try {
        categorySearchLoading.value = true;

        // Carregar categorias se ainda não foram carregadas
        await loadAllCategories();

        console.log('🔍 Filtrando categorias localmente:', query);

        // Filtrar localmente
        const lowerQuery = query.toLowerCase();
        const filtered = allCategories.value.filter(cat =>
          cat.nome.toLowerCase().includes(lowerQuery) ||
          cat.caminho.toLowerCase().includes(lowerQuery)
        );

        // Limitar a 20 resultados
        categorySearchResults.value = filtered.slice(0, 20);

        console.log('✅ Categorias filtradas:', categorySearchResults.value.length);

      } catch (error) {
        console.error('❌ Erro ao buscar categorias:', error);
        categorySearchResults.value = [];

      } finally {
        categorySearchLoading.value = false;
      }
    }

    function handleCategorySearch(event, groupIndex, condIndex) {
      const query = event.target.value;

      // Update the search query for this specific field
      const key = `${groupIndex}-${condIndex}`;
      categorySearchQuery.value[key] = query;
      activeCategorySearch.value = key;

      // Clear existing timeout
      if (categorySearchTimeout) {
        clearTimeout(categorySearchTimeout);
      }

      // Set new timeout for debounced search
      categorySearchTimeout = setTimeout(() => {
        searchCategories(query, groupIndex, condIndex);
      }, 300);
    }

    function selectCategory(category, groupIndex, condIndex) {
      const condition = groups.value[groupIndex].conditions[condIndex];
      condition.valueUuid = category.id;

      // Store category name in valueText for display
      const key = `${groupIndex}-${condIndex}`;
      categorySearchQuery.value[key] = category.nome;

      // Close dropdown
      activeCategorySearch.value = null;
      categorySearchResults.value = [];

      updateSegmentData();
    }

    function closeCategorySearch() {
      activeCategorySearch.value = null;
      categorySearchResults.value = [];
    }

    function getCategorySearchQuery(groupIndex, condIndex) {
      const key = `${groupIndex}-${condIndex}`;
      return categorySearchQuery.value[key] || '';
    }

    function isCategorySearchActive(groupIndex, condIndex) {
      const key = `${groupIndex}-${condIndex}`;
      return activeCategorySearch.value === key;
    }

    // Color and Size dropdown functions
    async function loadAllColors() {
      if (allColors.value.length > 0) {
        return; // Já carregadas
      }

      try {
        if (!empresaId.value) {
          console.warn('Empresa ID não disponível para carregar cores');
          return;
        }

        console.log('🎨 Carregando cores disponíveis para empresa:', empresaId.value);

        const supabaseClient = wwLib.wwPlugins.supabaseAuth?.publicInstance;

        if (!supabaseClient) {
          throw new Error('Supabase client not available');
        }

        const functionName = `produtos-attributes?empresa_id=${empresaId.value}&attribute=colors`;
        console.log('📡 Calling function:', functionName);

        const response = await supabaseClient.functions.invoke(functionName);

        if (response.error) {
          console.error('❌ Erro ao carregar cores:', response.error);
          throw response.error;
        }

        console.log('✅ Cores carregadas:', response.data);

        allColors.value = Array.isArray(response.data) ? response.data : [];

        console.log('✅ Total de cores:', allColors.value.length);

      } catch (error) {
        console.error('❌ Erro ao carregar cores:', error);
        allColors.value = [];
      }
    }

    async function loadAllSizes() {
      if (allSizes.value.length > 0) {
        return; // Já carregadas
      }

      try {
        if (!empresaId.value) {
          console.warn('Empresa ID não disponível para carregar tamanhos');
          return;
        }

        console.log('👕 Carregando tamanhos disponíveis para empresa:', empresaId.value);

        const supabaseClient = wwLib.wwPlugins.supabaseAuth?.publicInstance;

        if (!supabaseClient) {
          throw new Error('Supabase client not available');
        }

        const functionName = `produtos-attributes?empresa_id=${empresaId.value}&attribute=sizes`;
        console.log('📡 Calling function:', functionName);

        const response = await supabaseClient.functions.invoke(functionName);

        if (response.error) {
          console.error('❌ Erro ao carregar tamanhos:', response.error);
          throw response.error;
        }

        console.log('✅ Tamanhos carregados:', response.data);

        allSizes.value = Array.isArray(response.data) ? response.data : [];

        console.log('✅ Total de tamanhos:', allSizes.value.length);

      } catch (error) {
        console.error('❌ Erro ao carregar tamanhos:', error);
        allSizes.value = [];
      }
    }

    function updateSegmentData() {
      const payload = buildPayload();
      setSegmentData(payload);
    }

    function buildPayload() {
      return {
        empresa: empresaId.value,
        nome: segmentName.value,
        descricao: segmentDescription.value,
        groups: groups.value.map(group => ({
          groupNumber: group.groupNumber,
          conditions: group.conditions
            .filter(c => c.field)
            .flatMap(c => {
              // Handle product_criteria specially - convert to multiple conditions
              if (c.field === 'product_criteria') {
                return buildProductCriteriaConditions(c);
              }

              // Handle legacy fields
              if (!c.operator) return [];

              const conditionsArray = [];

              // Build main condition
              let actualFieldName = c.field;
              if (c.field === 'produto') {
                actualFieldName = c.operator === '=' ? 'product_id' : 'product_name';
              } else if (c.field === 'categoria') {
                actualFieldName = c.operator === '=' ? 'product_category_id' : 'product_category_name';
              }

              const condition = {
                field: actualFieldName,
                operator: c.operator,
              };

              if (c.valueText) condition.valueText = c.valueText;
              if (c.valueUuid) condition.valueUuid = c.valueUuid;
              if (c.valueMin !== null && c.valueMin !== undefined) condition.valueMin = c.valueMin;
              if (c.valueMax !== null && c.valueMax !== undefined) condition.valueMax = c.valueMax;
              if (c.valueList?.length > 0) condition.valueList = c.valueList;

              if (supportsTemporalFilter(c.field)) {
                condition.timeOperator = c.timeOperator;
                if (c.timeOperator === 'in_the_last' && c.days) {
                  condition.days = c.days;
                }
                if (c.timeOperator === 'between_dates' && c.startDate && c.endDate) {
                  condition.startDate = c.startDate;
                  condition.endDate = c.endDate;
                }
              }

              conditionsArray.push(condition);

              // Add metrics if enabled for product or category
              if ((c.field === 'produto' || c.field === 'categoria') && c.enableMetrics) {
                const metricsConditions = buildMetricsConditions(c);
                conditionsArray.push(...metricsConditions);
              }

              return conditionsArray;
            }),
        })),
      };
    }

    function buildMetricsConditions(condition) {
      const metricsConditions = [];

      // Quantity (product_purchase_count)
      if (condition.metricCount?.enabled && condition.metricCount.value !== null) {
        metricsConditions.push({
          field: 'product_purchase_count',
          operator: condition.metricCount.operator,
          valueMin: condition.metricCount.value,
          timeOperator: condition.timeOperator || 'over_all_time',
          ...(condition.timeOperator === 'in_the_last' && condition.days ? { days: condition.days } : {}),
          ...(condition.timeOperator === 'between_dates' && condition.startDate && condition.endDate
            ? { startDate: condition.startDate, endDate: condition.endDate } : {}),
        });
      }

      // Value (product_purchase_value)
      if (condition.metricValue?.enabled && condition.metricValue.value !== null) {
        metricsConditions.push({
          field: 'product_purchase_value',
          operator: condition.metricValue.operator,
          valueMin: condition.metricValue.value,
          timeOperator: condition.timeOperator || 'over_all_time',
          ...(condition.timeOperator === 'in_the_last' && condition.days ? { days: condition.days } : {}),
          ...(condition.timeOperator === 'between_dates' && condition.startDate && condition.endDate
            ? { startDate: condition.startDate, endDate: condition.endDate } : {}),
        });
      }

      // Recency (product_purchase_recency) - NO temporal filter
      if (condition.metricRecency?.enabled && condition.metricRecency.value !== null) {
        metricsConditions.push({
          field: 'product_purchase_recency',
          operator: condition.metricRecency.operator,
          valueMin: condition.metricRecency.value,
          // Note: product_purchase_recency does NOT support temporal filters
        });
      }

      return metricsConditions;
    }

    function buildProductCriteriaConditions(criteria) {
      const conditions = [];

      // Validate product value is provided
      if (!criteria.productValue) return conditions;

      // Determine field name based on type and operator
      const isProduct = criteria.productType === 'produto';
      const isEqualOperator = criteria.productOperator === '=';

      const productFieldName = isProduct
        ? (isEqualOperator ? 'product_id' : 'product_name')
        : (isEqualOperator ? 'product_category_id' : 'product_category_name');

      // Create base product condition
      const productCondition = {
        field: productFieldName,
        operator: criteria.productOperator,
        timeOperator: criteria.timeOperator || 'over_all_time',
      };

      // Add value (UUID for "=" operator, text for others)
      if (isEqualOperator) {
        productCondition.valueUuid = criteria.productValue;
      } else {
        productCondition.valueText = criteria.productValue;
      }

      // Add temporal filter if applicable
      if (criteria.timeOperator === 'in_the_last' && criteria.days) {
        productCondition.days = criteria.days;
      } else if (criteria.timeOperator === 'between_dates' && criteria.startDate && criteria.endDate) {
        productCondition.startDate = criteria.startDate;
        productCondition.endDate = criteria.endDate;
      }

      conditions.push(productCondition);

      // Add metric conditions if enabled
      if (criteria.enableMetrics) {
        // Quantity (product_purchase_count)
        if (criteria.metricCount?.enabled && criteria.metricCount.value !== null) {
          conditions.push({
            field: 'product_purchase_count',
            operator: criteria.metricCount.operator,
            valueMin: criteria.metricCount.value,
            timeOperator: criteria.timeOperator || 'over_all_time',
            ...(criteria.timeOperator === 'in_the_last' && criteria.days ? { days: criteria.days } : {}),
            ...(criteria.timeOperator === 'between_dates' && criteria.startDate && criteria.endDate
              ? { startDate: criteria.startDate, endDate: criteria.endDate } : {}),
          });
        }

        // Value (product_purchase_value)
        if (criteria.metricValue?.enabled && criteria.metricValue.value !== null) {
          conditions.push({
            field: 'product_purchase_value',
            operator: criteria.metricValue.operator,
            valueMin: criteria.metricValue.value,
            timeOperator: criteria.timeOperator || 'over_all_time',
            ...(criteria.timeOperator === 'in_the_last' && criteria.days ? { days: criteria.days } : {}),
            ...(criteria.timeOperator === 'between_dates' && criteria.startDate && criteria.endDate
              ? { startDate: criteria.startDate, endDate: criteria.endDate } : {}),
          });
        }

        // Recency (product_purchase_recency) - NO temporal filter
        if (criteria.metricRecency?.enabled && criteria.metricRecency.value !== null) {
          conditions.push({
            field: 'product_purchase_recency',
            operator: criteria.metricRecency.operator,
            valueMin: criteria.metricRecency.value,
            // Note: product_purchase_recency does NOT support temporal filters
          });
        }
      }

      return conditions;
    }

    function hasFieldError(condition, fieldName) {
      if (!showValidation.value) return false;

      if (fieldName === 'field') {
        return !condition.field;
      } else if (fieldName === 'operator') {
        return !condition.operator;
      } else if (fieldName === 'valueMin') {
        const fieldType = getFieldType(condition.field);
        if (fieldType === 'numeric' || fieldType === 'boolean') {
          return condition.valueMin === null || condition.valueMin === undefined;
        }
        return false;
      } else if (fieldName === 'valueMax') {
        const fieldType = getFieldType(condition.field);
        if (fieldType === 'numeric' && condition.operator === 'between') {
          return condition.valueMax === null || condition.valueMax === undefined;
        }
        return false;
      } else if (fieldName === 'valueText') {
        const fieldType = getFieldType(condition.field);
        if (fieldType === 'text') {
          return !condition.valueText || condition.valueText.trim() === '';
        }
        // For product field with operators "contains" or "starts_with"
        if (fieldType === 'product' && condition.operator !== '=') {
          return !condition.valueText || condition.valueText.trim() === '';
        }
        // For category field with operators "contains" or "starts_with"
        if (fieldType === 'category' && condition.operator !== '=') {
          return !condition.valueText || condition.valueText.trim() === '';
        }
        return false;
      } else if (fieldName === 'valueUuid') {
        const fieldType = getFieldType(condition.field);
        if (fieldType === 'uuid') {
          return !condition.valueUuid || condition.valueUuid.trim() === '';
        }
        // For product field with operator "="
        if (fieldType === 'product' && condition.operator === '=') {
          return !condition.valueUuid || condition.valueUuid.trim() === '';
        }
        // For category field with operator "="
        if (fieldType === 'category' && condition.operator === '=') {
          return !condition.valueUuid || condition.valueUuid.trim() === '';
        }
        return false;
      } else if (fieldName === 'days') {
        const fieldType = getFieldType(condition.field);
        if (fieldType === 'date' || (supportsTemporalFilter(condition.field) && condition.timeOperator === 'in_the_last')) {
          return !condition.days;
        }
        return false;
      } else if (fieldName === 'startDate') {
        const fieldType = getFieldType(condition.field);
        if ((fieldType === 'date' && condition.operator === 'between_dates') ||
            (supportsTemporalFilter(condition.field) && condition.timeOperator === 'between_dates')) {
          return !condition.startDate;
        }
        return false;
      } else if (fieldName === 'endDate') {
        const fieldType = getFieldType(condition.field);
        if ((fieldType === 'date' && condition.operator === 'between_dates') ||
            (supportsTemporalFilter(condition.field) && condition.timeOperator === 'between_dates')) {
          return !condition.endDate;
        }
        return false;
      }

      return false;
    }

    async function handleSave() {
      showValidation.value = true;

      if (!canSave.value || isSaving.value) {
        return;
      }

      // Fetch empresa from collections at the moment of save
      let empresa = null;

      try {
        const collections = wwLib.$store.getters['data/getCollections'];
        empresa = collections?.['2a7ebac6-154a-4af7-8337-411e42e6a35c']?.data?.[0]?.empresa;

        console.log('=== FETCH EMPRESA ===');
        console.log('Collections:', collections);
        console.log('User collection data:', collections?.['2a7ebac6-154a-4af7-8337-411e42e6a35c']?.data);
        console.log('Empresa fetched:', empresa);
        console.log('=====================');
      } catch (error) {
        console.error('Error fetching empresa:', error);
      }

      // Validate empresa
      if (!empresa) {
        alert('❌ Empresa não encontrada!\n\nA collection "user" não está carregada ou não contém dados de empresa.');
        return;
      }

      // Build payload with fetched empresa
      const payload = {
        empresa: empresa,
        nome: segmentName.value,
        descricao: segmentDescription.value,
        groups: groups.value.map(group => ({
          groupNumber: group.groupNumber,
          conditions: group.conditions
            .filter(c => c.field && c.operator)
            .map(c => {
              const condition = {
                field: c.field,
                operator: c.operator,
              };

              if (c.valueText) condition.valueText = c.valueText;
              if (c.valueUuid) condition.valueUuid = c.valueUuid;
              if (c.valueMin !== null && c.valueMin !== undefined) condition.valueMin = c.valueMin;
              if (c.valueMax !== null && c.valueMax !== undefined) condition.valueMax = c.valueMax;
              if (c.valueList?.length > 0) condition.valueList = c.valueList;

              if (supportsTemporalFilter(c.field)) {
                condition.timeOperator = c.timeOperator;
                if (c.timeOperator === 'in_the_last' && c.days) {
                  condition.days = c.days;
                }
                if (c.timeOperator === 'between_dates' && c.startDate && c.endDate) {
                  condition.startDate = c.startDate;
                  condition.endDate = c.endDate;
                }
              }

              return condition;
            }),
        })),
      };

      // Se estiver em modo edição, adicionar id e version
      if (isEditMode.value && props.content?.segmentId) {
        payload.id = parseInt(props.content.segmentId);
        payload.version = "2";
      }

      console.log('=== PAYLOAD COMPLETO ===');
      console.log(payload);
      console.log('========================');

      // Set loading state
      isSaving.value = true;

      try {
        // Get Supabase plugin
        const supabase = wwLib.wwPlugins?.supabase;

        if (!supabase) {
          throw new Error('Plugin Supabase não encontrado');
        }

        // Call the RPC function using Supabase instance directly
        const { data, error } = await supabase.instance.rpc(
          'front_segmento_criar_novo_v2',
          { payload: payload }
        );

        if (error) {
          throw error;
        }

        // Emit success event
        emit('trigger-event', {
          name: 'save-segment',
          event: {
            payload,
            result: data,
            success: true
          }
        });

        // Reset validation state after successful save
        showValidation.value = false;

        // Redirect to segmento page
        setTimeout(() => {
          isSaving.value = false;
          wwLib.goTo('/segmento');
        }, 500);

      } catch (error) {
        // Reset loading state on error
        isSaving.value = false;

        // Emit error event
        emit('trigger-event', {
          name: 'save-segment',
          event: {
            payload,
            error: error.message || 'Erro ao salvar segmento',
            success: false
          }
        });

        console.error('Erro ao salvar segmento:', error);
      }
    }

    function handleCancel() {
      emit('trigger-event', {
        name: 'cancel',
        event: {}
      });
    }

    watch([segmentName, segmentDescription, groups], updateSegmentData, { deep: true });

    return {
      segmentName,
      segmentDescription,
      groups,
      fieldCategories,
      canSave,
      showValidation,
      isSaving,
      empresaId,
      isEditMode,
      pageTitle,
      filterDescription,
      hasCompleteConditions,
      completeGroups,
      formatConditionDescription,
      getFieldType,
      getOperatorsForField,
      supportsTemporalFilter,
      hasFieldError,
      addGroup,
      removeGroup,
      addCondition,
      removeCondition,
      handleFieldChange,
      handleOperatorChange,
      handleSegmentNameChange,
      handleSegmentDescriptionChange,
      getDisplayDate,
      setDatePickerRef,
      openDatePicker,
      getBirthdayDisplayDate,
      setBirthdayPickerRef,
      openBirthdayPicker,
      handleBirthdayDateChange,
      handleSave,
      handleCancel,
      // Product autocomplete
      productSearchResults,
      productSearchQuery,
      productSearchLoading,
      handleProductSearch,
      selectProduct,
      closeProductSearch,
      getProductSearchQuery,
      isProductSearchActive,
      // Category autocomplete
      categorySearchResults,
      categorySearchQuery,
      categorySearchLoading,
      allCategories,
      handleCategorySearch,
      selectCategory,
      closeCategorySearch,
      getCategorySearchQuery,
      isCategorySearchActive,
      // Color and Size dropdowns
      allColors,
      allSizes,
      loadAllColors,
      loadAllSizes,
    };
  },
};
</script>

<style lang="scss" scoped>
* {
  box-sizing: border-box;
}

.segmentation-page {
  background-color: transparent;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  margin: 0;
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
  background-color: transparent;
  margin-bottom: 24px;
}

.page-title {
  margin: 0;
  font-family: 'Manrope', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  font-size: 24px;
  font-weight: 600;
  color: #1A1A1A;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.validation-message {
  padding: 8px 16px;
  background: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;

  &::before {
    content: '⚠';
    font-size: 16px;
  }
}

.btn-secondary {
  padding: 8px 20px;
  background: #ffffff;
  color: #000000;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s;

  &:hover {
    background: #f9fafb;
    border-color: #9ca3af;
  }
}

.btn-primary {
  padding: 8px 20px;
  background: #7c3aed;
  color: #ffffff;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s;

  &:hover:not(:disabled) {
    background: #6d28d9;
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  &.is-loading {
    opacity: 0.9;
    cursor: wait;
  }

  .loading-content {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .spinner {
    width: 16px;
    height: 16px;
    animation: spin 1s linear infinite;
  }

  .spinner-circle {
    stroke: currentColor;
    stroke-dasharray: 50;
    stroke-dashoffset: 25;
    stroke-linecap: round;
    animation: spinner-dash 1.5s ease-in-out infinite;
  }
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

@keyframes spinner-dash {
  0% {
    stroke-dashoffset: 50;
  }
  50% {
    stroke-dashoffset: 12.5;
  }
  100% {
    stroke-dashoffset: 50;
  }
}

/* Metrics Checkbox */
.metrics-checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-left: 12px;
}

.metrics-checkbox-label {
  font-size: 13px;
  color: #007aff;
  cursor: pointer;
  user-select: none;
  font-weight: 500;
}

/* Metrics Section Expanded */
.metrics-section-expanded {
  width: 100%;
  flex-basis: 100%;
  background: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  padding: 16px;
  margin-top: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.metric-row {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.metric-label {
  font-size: 13px;
  color: #555;
  min-width: 160px;
  cursor: pointer;
  user-select: none;
}

.select-field-tiny {
  padding: 4px 8px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 13px;
  min-width: 150px;
}

.select-field-tiny:disabled {
  background: #f5f5f5;
  color: #999;
  cursor: not-allowed;
}

.input-tiny {
  padding: 4px 8px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 13px;
  width: 100px;
}

.input-tiny:disabled {
  background: #f5f5f5;
  color: #999;
  cursor: not-allowed;
}

input[type="checkbox"] {
  cursor: pointer;
  width: 16px;
  height: 16px;
}

.page-content {
  padding: 0;
  margin: 0;
}

.section-card {
  background: #ffffff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  margin: 0;
}

.section-title {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #000000;
}

.section-description {
  margin: 0 0 24px 0;
  font-size: 13px;
  color: #6b7280;
  line-height: 1.5;
}

.fields-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 32px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-size: 13px;
  font-weight: 500;
  color: #374151;
}

.field-input {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  color: #000000;
  background: #ffffff;

  &::placeholder {
    color: #9ca3af;
  }

  &:focus {
    outline: none;
    border-color: #7c3aed;
    box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
  }

  &.has-error {
    border-color: #ef4444;
    background: #fef2f2;

    &:focus {
      border-color: #ef4444;
      box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
    }
  }
}

.builder-title {
  margin: 0 0 20px 0;
  font-size: 14px;
  font-weight: 500;
  color: #000000;
}

.conditions-area {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.group-box {
  background: #faf9fc;
  border-radius: 8px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.condition-row {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  flex-wrap: wrap;
}

.label-ou {
  padding: 0;
  background: transparent;
  color: #6b7280;
  font-size: 12px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  flex-shrink: 0;
  align-self: flex-start;
  margin-top: 0;
  margin-bottom: 8px;
}

.label-e {
  padding: 6px 16px;
  background: #7c3aed;
  color: #ffffff;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  width: fit-content;
  margin: 8px 0;
}

.condition-content {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  flex: 1;
}

.select-field,
.input-field,
.input-small,
.input-date {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 13px;
  color: #000000;
  background: #ffffff;

  &:focus {
    outline: none;
    border-color: #7c3aed;
    box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
  }

  &.has-error {
    border-color: #ef4444;
    background: #fef2f2;

    &:focus {
      border-color: #ef4444;
      box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
    }
  }
}

.select-field {
  min-width: 160px;
  background-image: url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%239ca3af' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 32px;
  appearance: none;
}

.input-field {
  flex: 1;
  min-width: 120px;
}

.input-small {
  width: 80px;
}

.input-date {
  width: 95px;
  cursor: pointer;
}

.date-picker-wrapper {
  position: relative;
  display: inline-block;
}

.hidden-date-picker {
  position: absolute;
  opacity: 0;
  pointer-events: none;
  width: 1px;
  height: 1px;
  top: 0;
  left: 0;
}

.text-label {
  font-size: 13px;
  color: #6b7280;
  font-weight: 400;
}

.btn-delete {
  padding: 6px;
  background: transparent;
  color: #dc2626;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;
  margin-left: auto;
  flex-shrink: 0;

  &:hover {
    background: #fee2e2;
  }

  svg {
    width: 16px;
    height: 16px;
  }
}

.group-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.btn-add-condition {
  padding: 8px 14px;
  background: transparent;
  color: #7c3aed;
  border: 2px dashed #c4b5fd;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  width: fit-content;
  display: flex;
  align-items: center;
  gap: 6px;

  &:hover {
    background: rgba(124, 58, 237, 0.05);
    border-color: #7c3aed;
  }

  .plus-icon {
    font-size: 16px;
    font-weight: 600;
  }
}

.btn-add-group {
  padding: 8px 14px;
  background: transparent;
  color: #7c3aed;
  border: 2px dashed #c4b5fd;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  width: fit-content;
  display: flex;
  align-items: center;
  gap: 6px;

  &:hover {
    background: rgba(124, 58, 237, 0.05);
    border-color: #7c3aed;
  }

  .plus-icon {
    font-size: 16px;
    font-weight: 600;
  }
}

/* Filter Description Section */
.filter-description-section {
  margin-top: 24px;
  padding: 20px;
  background: #fafafa;
  border-radius: 6px;
  border: none;
  border-left: none;
}

.description-title {
  margin: 0 0 12px 0;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  display: flex;
  align-items: center;
  gap: 6px;
  background: transparent;
  line-height: 1.4;

  svg {
    color: #9ca3af;
    flex-shrink: 0;
    width: 14px;
    height: 14px;
    margin-top: 1px;
  }
}

.description-content {
  padding: 0;
  border: none;
  border-left: none;
}

.description-intro {
  font-size: 13px;
  line-height: 1.5;
  color: #374151;
  margin-bottom: 16px;
  font-weight: 500;
  background: transparent;
}

.description-groups {
  display: flex;
  flex-direction: column;
  gap: 14px;
  background: transparent;
}

.description-group {
  padding-left: 0;
  background: transparent;
}

.group-header {
  display: flex;
  align-items: baseline;
  gap: 6px;
  margin-bottom: 8px;
  background: transparent;
}

.group-number {
  font-size: 13px;
  font-weight: 600;
  color: #7c3aed;
  line-height: 1;
  background: transparent;
}

.group-text {
  font-size: 12px;
  font-weight: 500;
  color: #6b7280;
  background: transparent;
}

.conditions-list {
  list-style: none;
  padding: 0;
  margin: 0;
  margin-left: 18px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  background: transparent;
}

.condition-item {
  font-size: 12px;
  line-height: 1.5;
  color: #374151;
  padding-left: 16px;
  position: relative;
  background: transparent;

  &::before {
    content: '•';
    position: absolute;
    left: 0;
    color: #9ca3af;
    font-weight: 400;
    font-size: 14px;
  }
}

.group-separator {
  text-align: center;
  font-size: 11px;
  font-weight: 600;
  color: #7c3aed;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin: 4px 0;
  padding: 8px 0;
  position: relative;
  background: transparent;

  &::before,
  &::after {
    content: '';
    position: absolute;
    top: 50%;
    width: calc(50% - 50px);
    height: 1px;
    background: linear-gradient(to right, transparent, #e5e7eb, transparent);
  }

  &::before {
    left: 0;
  }

  &::after {
    right: 0;
  }
}

/* Responsive */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .fields-row {
    grid-template-columns: 1fr;
  }

  .condition-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .label-ou {
    margin-top: 0;
  }

  .condition-content {
    width: 100%;

    .select-field,
    .input-field {
      width: 100%;
    }
  }

  .btn-delete {
    margin-left: 0;
    align-self: flex-end;
  }

  .filter-description-section {
    margin-top: 20px;
    padding: 16px;
  }

  .description-title {
    font-size: 12px;
  }

  .description-intro {
    font-size: 12px;
    margin-bottom: 14px;
  }

  .group-number {
    font-size: 12px;
  }

  .group-text {
    font-size: 11px;
  }

  .conditions-list {
    margin-left: 14px;
    gap: 5px;
  }

  .condition-item {
    font-size: 11px;
    padding-left: 14px;

    &::before {
      font-size: 12px;
    }
  }

  .group-separator {
    font-size: 10px;
    padding: 6px 0;

    &::before,
    &::after {
      width: calc(50% - 45px);
    }
  }
}

/* Product Autocomplete */
.autocomplete-wrapper {
  position: relative;
  flex: 1 1 auto;
  min-width: 200px;
  max-width: 100%;

  .input-field {
    width: 100%;
    flex: none;
  }
}

.autocomplete-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #ffffff;
  border: 1px solid #d0d0d0;
  border-top: none;
  border-radius: 0 0 4px 4px;
  max-height: 300px;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.autocomplete-loading {
  padding: 12px 16px;
  text-align: center;
  color: #666;
  font-size: 13px;
}

.autocomplete-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 16px;
  cursor: pointer;
  transition: background-color 0.15s;
  border-bottom: 1px solid #f0f0f0;

  &:last-child {
    border-bottom: none;
  }

  &:hover {
    background-color: #f9f9f9;
  }
}

.product-image {
  width: 40px;
  height: 40px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid #e0e0e0;
  flex-shrink: 0;
}

.product-info {
  flex: 1;
  min-width: 0;
}

.product-name {
  font-size: 13px;
  font-weight: 500;
  color: #333;
  margin-bottom: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.product-category {
  font-size: 11px;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Category Autocomplete */
.category-name-simple {
  font-size: 13px;
  font-weight: 400;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  flex: 1;
}

/* Color & Size Autocomplete */
.attribute-name {
  font-size: 13px;
  font-weight: 400;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  flex: 1;
}
</style>
