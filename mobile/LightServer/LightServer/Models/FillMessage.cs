using System;
using RestSharp.Portable;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Net.Http;

namespace LightServer {
    public class FillMessage {
        private int RedValue;
        private int BlueValue;
        private int GreenValue;
        private double Status;
        private string Mode;
        private Dictionary<String, String> Color;

        public FillMessage(double redValue, double blueValue, double greenValue) {
            RedValue = Convert.ToInt32(redValue);
            BlueValue = Convert.ToInt32(blueValue);
            GreenValue = Convert.ToInt32(greenValue);
        }

        async public void SendMessage() {
            // Not using Json here but just the get request for fills since its faster currently
            var colorURI = new UriBuilder("http", "10.0.0.14", 4567);
            colorURI.Path = string.Format("/fill/red/{0}/blue/{1}/green/{2}", RedValue, BlueValue, GreenValue);
            try {
                using (var client = new RestClient(colorURI.Uri)) {
                    var request = new RestRequest(HttpMethod.Get);
                    var result = await client.Execute<Object>(request);
                }
            } catch (Exception ex) {
            }
        }
    }
}

