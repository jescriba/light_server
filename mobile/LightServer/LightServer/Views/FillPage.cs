using System;

using Xamarin.Forms;

namespace LightServer {
    public class FillPage : ContentPage {
        public FillPage() {
            BackgroundColor = Color.Black;
            var redSlider = new Slider(128, 256, 128) 
            { 
                    VerticalOptions = LayoutOptions.CenterAndExpand,
                    BackgroundColor = Color.Red,
                    HeightRequest = 50
            };
            var blueSlider = new Slider(128, 256, 128) 
            {
                    BackgroundColor = Color.FromHex("#306EFF"),
                    HeightRequest = 50
            };
            var greenSlider = new Slider(128, 256, 129) 
            { 
                    VerticalOptions = LayoutOptions.CenterAndExpand,
                    BackgroundColor = Color.FromHex("#00EB00"),
                    HeightRequest = 50
            };
            var submitButton = new Button
            {
                    Text = "SUBMIT",
                    BackgroundColor = Color.FromHex("#1874CD"),
                    TextColor = Color.White,     
            };
            var offButton = new Button
            {
                    Text = "OFF",
                    BackgroundColor = Color.FromHex("#F62817"),
                    TextColor = Color.White,
            };
            var colorLayout = new StackLayout
            {
                    Spacing = 8,
                    Children = { redSlider, blueSlider, greenSlider },
            };

            var optionsLayout = new AbsoluteLayout
            {
                    VerticalOptions = LayoutOptions.FillAndExpand,
                    Children = { submitButton, offButton }
            };

            AbsoluteLayout.SetLayoutFlags(submitButton, AbsoluteLayoutFlags.All);
            AbsoluteLayout.SetLayoutFlags(offButton, AbsoluteLayoutFlags.All);
            AbsoluteLayout.SetLayoutBounds(submitButton, new Rectangle(0, 0.89, 1, 0.1));
            AbsoluteLayout.SetLayoutBounds(offButton, new Rectangle(0, 1, 1, 0.1));

            Content = new StackLayout
            { 
                    Padding = new Thickness(0, Device.OnPlatform(20, 0, 0), 0, 0),
                    Children = { colorLayout, optionsLayout }
            };

            submitButton.Clicked += (object sender, EventArgs e) => {
                var message = new FillMessage(redSlider.Value, blueSlider.Value, greenSlider.Value);
                message.SendMessage();
            };

            offButton.Clicked += (object sender, EventArgs e) => {
                var message = new FillMessage(128, 128, 128);
                message.SendMessage();
            };
        }
    }
}


