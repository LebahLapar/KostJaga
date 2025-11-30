import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/kost_provider.dart';
import '../../models/models.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final kostProvider = context.watch<KostProvider>();
    
    List<KostRoom> filteredRooms = _filterStatus == 'all'
        ? kostProvider.rooms
        : kostProvider.rooms.where((r) => r.status == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kamar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: kostProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredRooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada kamar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => kostProvider.fetchRooms(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return _buildRoomCard(context, room);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRoomDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kamar'),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, KostRoom room) {
    Color statusColor;
    IconData statusIcon;
    
    switch (room.status) {
      case 'available':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'occupied':
        statusColor = Colors.orange;
        statusIcon = Icons.person;
        break;
      case 'maintenance':
        statusColor = Colors.red;
        statusIcon = Icons.construction;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showRoomDetail(room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.meeting_room,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kamar ${room.roomNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(room.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRoomTypeText(room.type),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(room.price),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditRoomDialog(room);
                  } else if (value == 'delete') {
                    _confirmDelete(room);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'Tersedia';
      case 'occupied':
        return 'Terisi';
      case 'maintenance':
        return 'Maintenance';
      default:
        return status;
    }
  }

  String _getRoomTypeText(String type) {
    switch (type) {
      case 'single':
        return 'Kamar Single';
      case 'double':
        return 'Kamar Double';
      case 'shared':
        return 'Kamar Shared';
      default:
        return type;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Kamar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Semua'),
              value: 'all',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Tersedia'),
              value: 'available',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Terisi'),
              value: 'occupied',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Maintenance'),
              value: 'maintenance',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomDetail(KostRoom room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kamar ${room.roomNumber}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Tipe', _getRoomTypeText(room.type)),
              _buildDetailRow('Status', _getStatusText(room.status)),
              _buildDetailRow(
                'Harga',
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(room.price),
              ),
              if (room.description != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(room.description!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog() {
    final roomNumberController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'single';
    String selectedStatus = 'available';

    // Capture the scaffold context
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) => AlertDialog(
          title: const Text('Tambah Kamar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roomNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Kamar',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipe Kamar',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'single', child: Text('Single')),
                    DropdownMenuItem(value: 'double', child: Text('Double')),
                    DropdownMenuItem(value: 'shared', child: Text('Shared')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedType = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (roomNumberController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor kamar dan harga harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final room = KostRoom(
                  id: '',
                  roomNumber: roomNumberController.text,
                  type: selectedType,
                  price: double.tryParse(priceController.text) ?? 0,
                  status: selectedStatus,
                  description: descriptionController.text,
                  imageUrl: null,
                  createdAt: DateTime.now(),
                );

                final success =
                    await scaffoldContext.read<KostProvider>().addRoom(room);

                if (scaffoldContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (success) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                          content: Text('Kamar berhasil ditambahkan')),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRoomDialog(KostRoom room) {
    final roomNumberController = TextEditingController(text: room.roomNumber);
    final priceController =
        TextEditingController(text: room.price.toString());
    final descriptionController =
        TextEditingController(text: room.description ?? '');
    String selectedType = room.type;
    String selectedStatus = room.status;

    // Capture the scaffold context
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) => AlertDialog(
          title: const Text('Edit Kamar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roomNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Kamar',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipe Kamar',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'single', child: Text('Single')),
                    DropdownMenuItem(value: 'double', child: Text('Double')),
                    DropdownMenuItem(value: 'shared', child: Text('Shared')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedType = value!);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'available', child: Text('Tersedia')),
                    DropdownMenuItem(value: 'occupied', child: Text('Terisi')),
                    DropdownMenuItem(
                        value: 'maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedStatus = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updates = {
                  'room_number': roomNumberController.text,
                  'type': selectedType,
                  'status': selectedStatus,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'description': descriptionController.text,
                };

                final success = await scaffoldContext
                    .read<KostProvider>()
                    .updateRoom(room.id, updates);

                if (scaffoldContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (success) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(content: Text('Kamar berhasil diupdate')),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(KostRoom room) {
    // Capture the scaffold context
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Kamar'),
        content:
            Text('Apakah Anda yakin ingin menghapus kamar ${room.roomNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success =
                  await scaffoldContext.read<KostProvider>().deleteRoom(room.id);

              if (scaffoldContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Kamar berhasil dihapus')),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}