
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorios',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: ReminderListScreen(),
    );
  }
}

class ReminderListScreen extends StatefulWidget {
  @override
  _ReminderListScreenState createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<Reminder> reminders = [];
  List<bool> selectedReminders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reminders[index].title),
            subtitle: Text(reminders[index].formattedDate()),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ReminderDetailsScreen(reminder: reminders[index])));
            },
            selected: selectedReminders[index],
            trailing: Checkbox(
              value: reminders[index].isCompleted,
              onChanged: (value) {
                setState(() {
                  reminders[index].isCompleted = value ?? false;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReminderScreen(
                onAddReminder: (Reminder newReminder) {
                  setState(() {
                    reminders.add(newReminder);
                    selectedReminders.add(false);
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Recordatorios'),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                reminders.length,
                (index) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return CheckboxListTile(
                        title: Text(reminders[index].title),
                        value: selectedReminders[index],
                        onChanged: (value) {
                          setState(() {
                            selectedReminders[index] = value ?? false;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedReminders();
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedReminders() {
    for (int i = selectedReminders.length - 1; i >= 0; i--) {
      if (selectedReminders[i]) {
        setState(() {
          reminders.removeAt(i);
          selectedReminders.removeAt(i);
        });
      }
    }
  }
}
class AddReminderScreen extends StatefulWidget {
  final Function(Reminder) onAddReminder;

  AddReminderScreen({required this.onAddReminder});

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}


class _AddReminderScreenState extends State<AddReminderScreen> {
 
late String formattedDateTime = ''; 
 

  String title = '';
  DateTime dateTime = DateTime(2023, 12, 15, 5, 30);
 
  @override
 void initState() {
    super.initState();
    // Inicializar el plugin en initState

  }



  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Recordatorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Título'),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            const SizedBox(height: 20.0),
            Text(
              'Fecha y Hora: $formattedDateTime',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Seleccionar Fecha y Hora'),
              style: ElevatedButton.styleFrom(primary: const Color.fromARGB(255, 210, 203, 201),
                 onPrimary: Colors.black),
              onPressed: pickDateTime,
            ),
            const SizedBox(height: 400.0),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  Reminder newReminder = Reminder(
                     id: DateTime.now().millisecondsSinceEpoch, // Genera un ID único basado en la marca de tiempo
                    title: title,
                    date: formattedDateTime,
                     dateTime: dateTime,
                  );
                  widget.onAddReminder(newReminder);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
              child: const Text('Añadir', style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickDateTime() async {
    DateTime? pickedDate = await pickDate();
    if (pickedDate == null) return;
    TimeOfDay? pickedTime = await pickTime();
    if (pickedTime == null) return;

    setState(() {
      dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
        formattedDateTime =
        '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    });
  }


   


  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      );

}

class Reminder {
  final int id;
  final String title;
  final String date;
   final DateTime dateTime;
  bool isCompleted;

  Reminder({
  required this.id,
    required this.title,
    required this.date,
     required this.dateTime,
    this.isCompleted = false,
  });

  String formattedDate() {
    return 'Fecha: $date';
  }
}

class ReminderDetailsScreen extends StatelessWidget {
  final Reminder reminder;

  ReminderDetailsScreen({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Recordatorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título: ${reminder.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha: ${reminder.date}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Completado: ${reminder.isCompleted ? 'Sí' : 'No'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
