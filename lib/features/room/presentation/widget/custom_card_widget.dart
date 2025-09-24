import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {
  const CustomCardWidget({super.key, required this.title, required this.subtitle, required this.iconData, required this.onTap, required this.buttonText, required this.buttonColor});


  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback onTap;
  final String buttonText;
  final Color buttonColor;


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [

            Icon(
              iconData,
              size: 100,
            ),

            const SizedBox(height: 15,),

            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15,),

            Text(
              subtitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600
              ),
            ),

            const SizedBox(height: 15,),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                ),
                onPressed: () {},

                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
