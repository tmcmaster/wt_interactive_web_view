import { LitElement, html, css } from 'https://unpkg.com/lit@2.4.0?module';

class IntegerSlider extends LitElement {
  static properties = {
    value: { type: Number, reflect: true },
    min: { type: Number },
    max: { type: Number },
    step: { type: Number }
  };

  constructor() {
    super();
    this.value = 0;
    this.min = 0;
    this.max = 100;
    this.step = 1;
  }

  static styles = css`
    :host {
      display: inline-block;
      font-family: Arial, sans-serif;
    }

    .container {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    button {
      width: 30px;
      height: 30px;
      font-size: 20px;
      text-align: center;
    }

    input[type="range"] {
      flex-grow: 1;
      margin: 0;
    }

    span {
        width: 30px;
        font-size: 20px;
        text-align: center;
    }
  `;

  render() {
    return html`
      <div class="container">
        <button @click="${this._decrement}">-</button>
        <input
          type="range"
          .value="${this.value}"
          .min="${this.min}"
          .max="${this.max}"
          .step="${this.step}"
          @input="${this._onInput}">
        <span>${this.value}</span>
        <button @click="${this._increment}">+</button>
      </div>
    `;
  }

  updated(changedProperties) {
    if (changedProperties.has('value')) {
      this.dispatchEvent(new CustomEvent('value-changed', {
        detail: { value: this.value },
        bubbles: true,
        composed: true
      }));
    }
  }

  _onInput(e) {
    this.value = Number(e.target.value);
  }

  _increment() {
    this.value = Math.min(this.value + this.step, this.max);
  }

  _decrement() {
    this.value = Math.max(this.value - this.step, this.min);
  }
}

customElements.define('integer-slider', IntegerSlider);
