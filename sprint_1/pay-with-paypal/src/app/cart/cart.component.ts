import {Component, OnInit, ViewChild} from '@angular/core';
import {
  IPayPalConfig,
  ICreateOrderRequest
} from 'ngx-paypal';
import {CurrencyExchangeService} from '../currency-exchange.service';

@Component({
  selector: 'app-cart',
  templateUrl: './cart.component.html',
  styleUrls: ['./cart.component.css']
})
export class CartComponent implements OnInit {
  public payPalConfig ?: IPayPalConfig;
  firstItemPrice = 100000;
  firstItemQuantity = 1;
  secondItemPrice = 500000;
  secondItemQuantity = 1;
  total: number;
  rate: number;
  firstItemUSD: string;
  secondItemUSD: string;
  totalUSD: string;
  totalFirstUSD: string;
  totalSecondUSD: string;
  @ViewChild('myModal') myModal;
  display = 'none';
  isCancel = false;
  isSuccess = false;
  isError = false;

  constructor(private currencyExchangeService: CurrencyExchangeService) {
  }

  ngOnInit(): void {
    this.initConfig();
    this.getTotal();

    this.currencyExchangeService.getRate().subscribe(data => {
      this.rate = data['result'];
    });

  }

  private initConfig(): void {

    this.payPalConfig = {
      currency: 'USD',
      clientId: 'AYEhWF15yjs4kqngtEVpTs3wSAwNJKlg-XFf7Dogm9sHO3qzuXjKjvEK7O7m-aCx-83wAH91ABiEqkZ-',
      createOrderOnClient: (data) => <ICreateOrderRequest> {
        intent: 'CAPTURE',
        purchase_units: [{
          amount: {
            currency_code: 'USD',
            value: this.totalUSD,
            breakdown: {
              item_total: {
                currency_code: 'USD',
                value: this.totalUSD
              }
            }
          },
          items: [
            {
              name: 'product 1',
              quantity: this.firstItemQuantity.toString(),
              category: 'DIGITAL_GOODS',
              unit_amount: {
                currency_code: 'USD',
                value: this.firstItemUSD,
              }
            },
            {
              name: 'product 2',
              quantity: this.secondItemQuantity.toString(),
              category: 'DIGITAL_GOODS',
              unit_amount: {
                currency_code: 'USD',
                value: this.secondItemUSD,
              }
            }
          ]
        }]
      },
      advanced: {
        commit: 'true',
        extraQueryParams: [{name: 'disable-funding', value: 'credit,card'}]
      },
      style: {
        label: 'pay',
        shape: 'pill',
        layout: 'vertical',
      },
      onApprove: (data, actions) => {
        console.log('onApprove - transaction was approved, but not authorized', data, actions);
        actions.order.get().then(details => {
          console.log('onApprove - you can get full order details inside onApprove: ', details);
        });
      },
      onClientAuthorization: (data) => {
        console.log('onClientAuthorization - you should probably inform your server about completed transaction at this point', data);
        this.isCancel = false;
        this.isError = false;
        this.isSuccess = true;
        this.openModal();
      },
      onCancel: (data, actions) => {
        console.log('OnCancel', data, actions);
        this.isCancel = true;
        this.isError = false;
        this.isSuccess = false;
        this.openModal();

      },
      onError: err => {
        console.log('OnError', err);
        this.isCancel = false;
        this.isError = true;
        this.isSuccess = false;
        this.openModal();

      },
      onClick: (data, actions) => {
        this.changeRate();
        console.log('onClick', data, actions);
        this.isCancel = false;
        this.isError = false;
        this.isSuccess = false;
      }
    };
  }

  getTotal() {
    this.total = this.firstItemPrice * this.firstItemQuantity + this.secondItemPrice * this.secondItemQuantity;
  }

  decreaseProduct(item: number) {
    switch (item) {
      case 1: {
        if (this.firstItemQuantity < 2) {
          this.firstItemQuantity = 1;
        } else {
          this.firstItemQuantity -= 1;
        }
        break;
      }
      case 2: {
        if (this.secondItemQuantity < 2) {
          this.secondItemQuantity = 1;
        } else {
          this.secondItemQuantity -= 1;
        }
        break;
      }
    }
    this.getTotal();
  }

  increaseProduct(item: number) {
    switch (item) {
      case 1: {
        this.firstItemQuantity += 1;
        break;
      }
      case 2: {
        this.secondItemQuantity += 1;
        break;
      }
    }
    this.getTotal();
  }

  changeRate() {
    this.firstItemUSD = (this.firstItemPrice / this.rate).toFixed(2);
    this.secondItemUSD = (this.secondItemPrice / this.rate).toFixed(2);
    this.totalFirstUSD = (Number(this.firstItemUSD) * this.firstItemQuantity).toFixed(2);
    this.totalSecondUSD = (Number(this.secondItemUSD) * this.secondItemQuantity).toFixed(2);
    this.totalUSD = (Number(this.totalFirstUSD) + Number(this.totalSecondUSD)).toFixed(2);
    console.log(this.totalFirstUSD);
    console.log(this.totalSecondUSD);
    console.log(this.totalUSD);
  }

  openModal() {
    this.display = 'block';
  }

  closeModal() {
    this.display = 'none';
  }

}
