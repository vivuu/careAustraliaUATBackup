import { LightningElement, wire, api, track } from 'lwc';
//importing the Chart library from Static resources
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//importing the apex method.
import getLoanTypeCount from '@salesforce/apex/LWC_AllLoansCtrl.getLoanTypeCount';

export default class Lwr_donutChart extends LightningElement {
   @api contactid;
   error;
   @track staticcolours = ['rgb(71, 33, 117)', 'rgb(92, 143, 57)', 'rgb(228, 118, 30)', 'rgb(172, 56, 30)', 'rgb(254, 190, 42)'];

   connectedCallback() {
      for (let i = 0; i < 10; i++) {
         this.staticcolours.push(this.getRandomRgb());
      }
   }

   getRandomRgb() {
      const num = Math.round(0xffffff * Math.random());
      const r = num >> 16;
      const g = (num >> 8) & 255;
      const b = num & 255;
      return `rgb(${r}, ${g}, ${b})`;
   }



   @wire(getLoanTypeCount, { contactid: '$contactid' }) Types({ error, data }) {
      if (data) {
         console.log("@@@@@data@@@@@" + this.contactid+JSON.stringify(data));
         for (var key in data) {
            this.updateChart(data[key].count, data[key].label);
         }
         this.error = undefined;
      }
      else if (error) {
         this.error = error;
         this.Types = undefined;
      }
   }
   chart;
   chartjsInitialized = false;
   config = {
      type: 'doughnut',
      data: {
         datasets: [
            {
               data: [
               ],
               backgroundColor: this.staticcolours,
               label: 'Dataset 1'
            }
         ],
         labels: []
      },
      options: {
         responsive: true,
         legend: {
            position: 'bottom'
         },
         animation: {
            animateScale: true,
            animateRotate: true
         }
      }
   };
   renderedCallback() {
      if (this.chartjsInitialized) {
         return;
      }
      this.chartjsInitialized = true;
      Promise.all([
         loadScript(this, chartjs)
      ]).then(() => {
         const ctx = this.template.querySelector('canvas.donut')
            .getContext('2d');
         this.chart = new window.Chart(ctx, this.config);
      })
         .catch(error => {
            this.dispatchEvent(
               new ShowToastEvent({
                  title: 'Error loading ChartJS',
                  message: error.message,
                  variant: 'error',
               }),
            );
         });
   }
   updateChart(count, label) {

      this.chart.data.labels.push(label);
      this.chart.data.datasets.forEach((dataset) => {
         dataset.data.push(count);
      });
      this.chart.update();
   }
}